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

SELECT * FROM booking_platform.GetAvailableSeatsForTrip(1);