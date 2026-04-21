--1. При создании билета автоматически создать платеж.
CREATE FUNCTION booking_platform.create_payment()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO booking_platform.payments(ticket_id, amount, currency, mathod, status)
    VALUES(
        NEW.id,
        NEW.total_price,
        NEW.currency,
        'card',
        'pending'
    );

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_ticket_created
AFTER INSERT ON booking_platform.tickets
FOR EACH ROW
EXECUTE FUNCTION booking_platform.create_payment();

--Создать бронирование, которое создаст и билет.
CALL booking_platform.CreateBooking(2, 1, 2, 14555, 'RUB');

--Проверить созданный платеж
SELECT *
FROM booking_platform.payments
ORDER BY created_at DESC
LIMIT 1;

--2. Запрет смены статуса рейса назад.
CREATE OR REPLACE FUNCTION booking_platform.reject_trip_status_change()
RETURNS TRIGGER AS $$
BEGIN

    IF (OLD.status = 'cancelled' AND NEW.status != 'cancelled'
        OR OLD.status = 'completed' AND NEW.status != 'completed') THEN
        RAISE EXCEPTION 'Cannot change trip status from "%" to "%"', OLD.status, NEW.status;
    END IF;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_trip_status_update
BEFORE UPDATE ON booking_platform.trips
FOR EACH ROW
EXECUTE FUNCTION booking_platform.reject_trip_status_change();

-- Посмотреть текущие статусы рейсов
SELECT id, status FROM booking_platform.trips LIMIT 5;

-- Принудительно поставить статус 'cancelled' для теста
UPDATE booking_platform.trips SET status = 'cancelled' WHERE id = 1;

-- Попытка сменить обратно — должна выдать EXCEPTION
UPDATE booking_platform.trips SET status = 'scheduled' WHERE id = 1;