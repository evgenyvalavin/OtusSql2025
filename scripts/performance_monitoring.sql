-- 1.
--pg_stat_statements — это расширение PostgreSQL для мониторинга производительности SQL-запросов. Оно собирает статистику по всем выполняемым запросам, что позволяет анализировать, какие запросы самые "тяжёлые", часто выполняются или требуют оптимизации.

--Включить расширение
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

--Добавить в файл конфигруации Postgres:
--shared_preload_libraries = 'pg_stat_statements'

--Отобразить завпросы. При желении можно фильтровать как нужно чтобы найти самые тяжелые запросы.
SELECT *
FROM pg_stat_statements;


-- 2.
-- Отобразить активные процессы
SELECT * FROM pg_stat_activity;

-- 3. В PgAdmin можем посмотреть использование CPU/RAM. В диспетчере задач (Windows) или top (ubuntu) чтобы посмотреть использование CPU/RAM.

-- 4. Отобразить план запроса через: EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM booking_platform.UpcomingTrips;


-- 5.
-- VACUUM (и AUTOVACUUM) помогает очистить страницы от “мёртвых” строк
-- Следить за числом мёртвых строк в таблице можно по представлению:
-- n_dead_tup	Number of dead (not yet vacuumed) rows
-- n_live_tup	Number of live rows
-- last_autovacuum	Timestamp of last autovacuum run
-- last_vacuum	Timestamp of last manual VACUUM
SELECT 
    schemaname,
    relname AS table_name,
    n_dead_tup AS dead_tuples,
    n_live_tup AS live_tuples,
    last_vacuum,
    last_autovacuum
FROM pg_catalog.pg_stat_all_tables
ORDER BY n_dead_tup DESC;