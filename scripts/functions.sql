--1.
CREATE OR REPLACE FUNCTION booking_platform.GetActiveTripsInJson()
RETURNS json
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT json_agg(t)
        FROM (SELECT * FROM booking_platform.trips WHERE status NOT IN ('completed', 'cancelled')) t
    );
END;
$$;
COMMENT ON FUNCTION booking_platform.GetActiveTripsInJson()
    IS 'Возвращает список всех активных поездок (кроме завершённых и отменённых) в формате JSON.';

SELECT booking_platform.GetActiveTripsInJson() AS active_trips;

--2.
CREATE OR REPLACE FUNCTION booking_platform.CalculateTripRevenue(p_id INT)
RETURNS NUMERIC(12, 2)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM booking_platform.bookings WHERE trip_id = p_id AND status = 'confirmed') THEN
        RAISE EXCEPTION 'No trip exists for id "%" or the trip is not confirmed', p_id;
    END IF;

    RETURN (
        SELECT SUM(t.total_price) FROM booking_platform.bookings b
        JOIN booking_platform.tickets t ON b.id = t.booking_id
        WHERE b.trip_id = p_id
            AND t.is_returned = FALSE
            AND b.status = 'confirmed'
    );
END;
$$;
COMMENT ON FUNCTION booking_platform.CalculateTripRevenue(INT)
    IS 'Вычисляет суммарную выручку по подтверждённым бронированиям для указанной поездки (p_id). Учитывает только невозвращённые билеты. Генерирует исключение, если подтверждённых бронирований не найдено.';

SELECT booking_platform.CalculateTripRevenue(1);

--3.
CREATE OR REPLACE FUNCTION booking_platform.GetAvailableSeatsForTrip(p_id INT)
RETURNS TABLE(seat INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM booking_platform.trips WHERE id = p_id) THEN
        RAISE EXCEPTION 'No trip exits for id "%"', p_id;
    END IF;

    RETURN QUERY(
        SELECT s.id FROM booking_platform.trips t
        JOIN booking_platform.seats s ON s.vehicle_id = t.vehicle_id
        WHERE t.id = p_id
            AND s.is_available = TRUE
            AND s.id NOT IN (
                SELECT b.seat_id
                FROM booking_platform.bookings b 
                WHERE b.trip_id = t.id AND b.status <> 'cancelled'
            )
    );
END;
$$;
COMMENT ON FUNCTION booking_platform.GetAvailableSeatsForTrip(INT)
    IS 'Возвращает список идентификаторов свободных мест для указанной поездки (p_id). Место считается свободным, если оно доступно (is_available = TRUE) и не занято ни одним активным бронированием. Генерирует исключение, если поездка с указанным id не найдена.';

SELECT * FROM booking_platform.GetAvailableSeatsForTrip(1);

--4.
CREATE OR REPLACE FUNCTION booking_platform.GetTripDistance(p_id INT)
RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM booking_platform.trips WHERE id = p_id) THEN
        RAISE EXCEPTION 'No trip exists for id "%"', p_id;
    END IF;

    RETURN (
        SELECT ROUND((ST_Distance(s_origin.location, s_dest.location))::NUMERIC, 2)
        FROM booking_platform.trips t
        JOIN booking_platform.routes r ON r.id = t.route_id
        JOIN booking_platform.stations s_origin ON s_origin.id = r.origin_station_id
        JOIN booking_platform.stations s_dest ON s_dest.id = r.dest_station_id
        WHERE t.id = p_id
    );
END;
$$;
COMMENT ON FUNCTION booking_platform.GetTripDistance(INT)
    IS 'Возвращает расстояние между станцией отправления и станцией назначения маршрута указанного рейса (p_id) в метрах. Использует географические координаты станций. Генерирует исключение, если рейс с указанным id не найден.';

SELECT booking_platform.GetTripDistance(1);

--Отобразить все комментарии к созданным функциям
SELECT p.proname AS function_name, d.description
FROM pg_proc p
JOIN pg_description d ON d.objoid = p.oid
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'booking_platform';