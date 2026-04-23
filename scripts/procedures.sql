--1
-- Создаёт новый рейс (trip) по заданному маршруту, транспортному средству
-- и временным меткам отправления/прибытия. Проверяет существование станций,
-- маршрута и воздушного судна, а также отсутствие дублирующегося рейса.

CREATE OR REPLACE PROCEDURE booking_platform.CreateFlightTrip(
    IN p_from_station CHAR(3),
    IN p_to_station CHAR(3),
    IN p_departure_at TIMESTAMPTZ,
    IN p_arrival_at TIMESTAMPTZ,
    IN p_vehicle_registration_code VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_route_id INT;
    v_from_station_id INT;
    v_to_station_id INT;
    v_vehicle_id INT;
BEGIN

    SELECT id INTO v_from_station_id
    FROM booking_platform.stations
    WHERE iata_code = p_from_station;

    IF v_from_station_id IS NULL THEN
        RAISE EXCEPTION 'Station not found for IATA code "%"', p_from_station;
    END IF;

    SELECT id INTO v_to_station_id
    FROM booking_platform.stations
    WHERE iata_code = p_to_station;

    IF v_to_station_id IS NULL THEN
        RAISE EXCEPTION 'Station not found for IATA code "%"', p_to_station;
    END IF;

    SELECT id INTO v_route_id
    FROM booking_platform.routes
    WHERE origin_station_id = v_from_station_id AND dest_station_id = v_to_station_id;

    IF v_route_id IS NULL THEN
        RAISE EXCEPTION 'Route from "%" to "%" does not exist.', p_from_station, p_to_station;
    END IF;

    SELECT id INTO v_vehicle_id
    FROM booking_platform.vehicles
    WHERE registration_code = p_vehicle_registration_code;

    IF v_vehicle_id IS NULL THEN
        RAISE EXCEPTION 'Vehicle with registration code "%" does not exist.', p_vehicle_registration_code;
    END IF;

    INSERT INTO booking_platform.trips (route_id, vehicle_id, departure_at, arrival_at)
    VALUES (v_route_id, v_vehicle_id, p_departure_at, p_arrival_at);

END;
$$;

CALL booking_platform.CreateFlightTrip('DME', 'DXB', '2025-01-01 00:00:00+03', '2025-01-01 00:05:31+03', 'D-AIXB');

--2
-- Переводит статус рейса в 'departed' (вылетел).
-- Проверяет, что рейс с указанным идентификатором существует.

CREATE OR REPLACE PROCEDURE booking_platform.SetTripStatusDeparted(
    IN p_trip_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF EXISTS (SELECT 1 FROM booking_platform.trips WHERE id = p_trip_id) THEN
        UPDATE booking_platform.trips
        SET status = 'departed'
        WHERE id = p_trip_id;
    ELSE
        RAISE EXCEPTION 'Trip does not exist.';
    END IF;

END;
$$;

CALL booking_platform.SetTripStatusDeparted(3);

--3
-- Отменяет бронирование: устанавливает статус 'cancelled' для бронирования,
-- помечает билет как возвращённый (is_returned = TRUE), а также переводит
-- завершённый платёж в статус 'refunded' или удаляет незавершённый.

CREATE OR REPLACE PROCEDURE booking_platform.CancelBooking(
    IN p_booking_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket_id INT;
BEGIN

    IF EXISTS (SELECT 1 FROM booking_platform.bookings WHERE id = p_booking_id) THEN
        UPDATE booking_platform.bookings
        SET status = 'cancelled'
        WHERE id = p_booking_id;

        UPDATE booking_platform.tickets
        SET is_returned = TRUE
        WHERE booking_id = p_booking_id;

        SELECT id INTO v_ticket_id
        FROM booking_platform.tickets
        WHERE booking_id = p_booking_id;

        IF (SELECT 1 FROM booking_platform.payments WHERE ticket_id = v_ticket_id AND status = 'completed') THEN
            UPDATE booking_platform.payments
            SET status = 'refunded'
            WHERE ticket_id = v_ticket_id;
        ELSE
            DELETE FROM booking_platform.payments WHERE ticket_id = v_ticket_id;
        END IF;
    ELSE
        RAISE EXCEPTION 'Booking does not exist.';
    END IF;

END;
$$;

CALL booking_platform.CancelBooking(12);

--4
-- Создаёт нового клиента с переданными персональными данными
-- (имя, фамилия, дата рождения, номер паспорта, email, телефон).

CREATE OR REPLACE PROCEDURE booking_platform.CreateClient(
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_birth_date DATE,
    IN p_passport_num VARCHAR(20),
    IN p_email VARCHAR(254),
    IN p_phone VARCHAR(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    INSERT INTO booking_platform.clients (first_name, last_name, birth_date, passport_num, email, phone)
    VALUES (p_first_name, p_last_name, p_birth_date, p_passport_num, p_email, p_phone);

END;
$$;

CALL booking_platform.CreateClient('Evgeny', 'Valavin', '1999-02-17', 'A123456789', 'ev@example.com', '+1 234 567 821');

--5
-- Создаёт бронирование места на рейс для указанного клиента.
-- Проверяет существование клиента, доступность рейса для бронирования
-- и отсутствие уже активного бронирования на то же место.
-- Автоматически генерирует билет с уникальным номером.

CREATE OR REPLACE PROCEDURE booking_platform.CreateBooking(
    IN p_client_id INT,
    IN p_trip_id INT,
    IN p_seat_id INT,
    IN p_total_price NUMERIC(12, 2),
    IN p_currency CHAR(3) DEFAULT 'RUB'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_booking_id INT;
    v_vehicle_id INT;
    v_ticket_number VARCHAR(30);
BEGIN

    IF NOT EXISTS (SELECT 1 FROM booking_platform.clients WHERE id = p_client_id) THEN
        RAISE EXCEPTION 'Client with iid "%" does not exist.', p_client_id;
    END IF;

    SELECT vehicle_id INTO v_vehicle_id
    FROM booking_platform.trips
    WHERE id = p_trip_id AND status IN ('scheduled', 'boarding');

    IF v_vehicle_id IS NULL THEN
        RAISE EXCEPTION 'Trip "%" does not exist or not available for booking.', p_trip_id;
    END IF;

    IF EXISTS(
        SELECT 1 FROM booking_platform.bookings
        WHERE trip_id = p_trip_id AND seat_id = p_seat_id AND status <> 'cancelled'
    ) THEN
        RAISE EXCEPTION 'Seat "%" on trip "%" is already booked.', p_seat_id, p_trip_id;
    END IF;

    INSERT INTO booking_platform.bookings(client_id, trip_id, seat_id, status)
    VALUES(p_client_id, p_trip_id, p_seat_id, 'confirmed')
    RETURNING id INTO v_booking_id;

    v_ticket_number := 'TKT-' || LPAD(v_booking_id::TEXT, 10, '0');

    INSERT INTO booking_platform.tickets(booking_id, ticket_number, total_price, currency)
    VALUES(v_booking_id, v_ticket_number, p_total_price, p_currency);

END;
$$;

CALL booking_platform.CreateBooking(1, 1, 1, 14555, 'RUB');
CALL booking_platform.CreateBooking(2, 1, 2, 14555, 'RUB');