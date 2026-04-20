-- Роли и управление доступом для схемы booking_platform
-- Три роли:
--   booking_app      — приложение (чтение + запись рабочих таблиц)
--   booking_readonly — аналитика / отчёты (только чтение)
--   booking_admin    — администратор (полный доступ)

-- ============================================================
-- 1. Создание ролей
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_app') THEN
        CREATE ROLE booking_app NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_readonly') THEN
        CREATE ROLE booking_readonly NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'booking_admin') THEN
        CREATE ROLE booking_admin NOLOGIN;
    END IF;
END;
$$;

-- ============================================================
-- 2. Права на схему
-- ============================================================

GRANT USAGE ON SCHEMA booking_platform TO booking_app, booking_readonly, booking_admin;
GRANT ALL ON SCHEMA booking_platform TO booking_admin;

-- ============================================================
-- 3. booking_readonly — только SELECT на все таблицы
-- ============================================================

GRANT SELECT ON ALL TABLES IN SCHEMA booking_platform TO booking_readonly;
-- Автоматически распространять на будущие таблицы
ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT SELECT ON TABLES TO booking_readonly;

-- ============================================================
-- 4. booking_app — рабочие права для приложения
-- ============================================================

-- Справочники: только чтение
GRANT SELECT ON
    booking_platform.transport_types,
    booking_platform.seat_classes
TO booking_app;

-- Оперативные таблицы: чтение + запись
GRANT SELECT, INSERT, UPDATE ON
    booking_platform.carries,
    booking_platform.vehicles,
    booking_platform.stations,
    booking_platform.routes,
    booking_platform.trips,
    booking_platform.seats,
    booking_platform.clients,
    booking_platform.bookings,
    booking_platform.tickets,
    booking_platform.payments
TO booking_app;

-- Доступ к последовательностям (GENERATED ALWAYS AS IDENTITY)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA booking_platform TO booking_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT USAGE ON SEQUENCES TO booking_app;

-- Запрет удаления данных клиентов из приложения (только admin)
REVOKE DELETE ON booking_platform.clients FROM booking_app;

-- Права на выполнение хранимых процедур и функций
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA booking_platform TO booking_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT EXECUTE ON ROUTINES TO booking_app;

-- ============================================================
-- 5. booking_admin — полный доступ
-- ============================================================

GRANT ALL ON ALL TABLES IN SCHEMA booking_platform TO booking_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA booking_platform TO booking_admin;
GRANT ALL ON ALL ROUTINES IN SCHEMA booking_platform TO booking_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT ALL ON TABLES TO booking_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT ALL ON SEQUENCES TO booking_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA booking_platform
    GRANT ALL ON ROUTINES TO booking_admin;

-- ============================================================
-- 6. Пользователи-примеры (с паролями из переменных окружения
--    или временными — обязательно сменить перед продом)
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user LOGIN PASSWORD 'change_me_app';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'report_user') THEN
        CREATE ROLE report_user LOGIN PASSWORD 'change_me_report';
    END IF;
END;
$$;

GRANT booking_app      TO app_user;
GRANT booking_readonly TO report_user;

-- ============================================================
-- 7. Проверка выданных прав
-- ============================================================

-- Список прав на таблицы схемы
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'booking_platform'
ORDER BY grantee, table_name, privilege_type;
