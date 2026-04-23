--1.
CREATE VIEW booking_platform.UpcomingTrips AS
    SELECT
        t.id,
        sd.name AS origin,
        sa.name AS destination,
        t.departure_at,
        t.arrival_at,
        v.model
    FROM booking_platform.trips t
    JOIN booking_platform.vehicles v ON v.id = t.vehicle_id
    JOIN booking_platform.routes r ON r.id = t.route_id
    JOIN booking_platform.stations sd ON sd.id = r.origin_station_id
    JOIN booking_platform.stations sa ON sa.id = r.dest_station_id
    WHERE t.status = 'scheduled';
COMMENT ON VIEW booking_platform.UpcomingTrips IS
    'Список предстоящих рейсов со статусом scheduled: маршрут (откуда/куда), время отправления и прибытия, модель транспортного средства.';

SELECT * FROM booking_platform.UpcomingTrips;

--2.
CREATE VIEW booking_platform.AvailableSeats AS
    SELECT
        t.id,
        t.departure_at,
        t.arrival_at,
        COUNT(s.id) AS total_seats,
        COUNT(b.id) AS booked_seats,
        COUNT(s.id) - COUNT(b.id) AS available_seats
    FROM booking_platform.trips t
    JOIN booking_platform.seats s ON s.vehicle_id = t.vehicle_id
    JOIN booking_platform.seat_classes sc ON s.seat_class_id = sc.id
    LEFT JOIN booking_platform.bookings b ON b.trip_id = t.id AND b.seat_id = s.id AND b.status IN ('confirmed', 'pending')
    GROUP BY t.id, sc.name;
COMMENT ON VIEW booking_platform.AvailableSeats IS
    'Количество мест по каждому рейсу: общее, забронированное (confirmed/pending) и доступное, сгруппированное по классу мест.';

SELECT * FROM booking_platform.AvailableSeats;

--3.
CREATE VIEW booking_platform.ClientBookingHistory AS
    SELECT
        c.id AS client_id,
        c.first_name || ' ' || c.last_name AS client_name,
        b.id AS booking_id,
        b.status AS booking_status,
        so.name AS origin,
        sd.name AS destination,
        t.departure_at AS departure_at,
        sc.name AS class,
        s.seat_number AS seat,
        tickets.ticket_number AS ticket_number,
        tickets.total_price AS price,
        tickets.currency AS currency,
        p.status AS payment_status
    FROM booking_platform.clients c
    JOIN booking_platform.bookings b ON b.client_id = c.id
    JOIN booking_platform.trips t ON t.id = b.trip_id
    JOIN booking_platform.routes r ON r.id = t.route_id
    JOIN booking_platform.stations so ON so.id = r.origin_station_id
    JOIN booking_platform.stations sd ON sd.id = r.dest_station_id
    JOIN booking_platform.seats s ON s.id = b.seat_id
    JOIN booking_platform.seat_classes sc ON sc.id = s.seat_class_id
    LEFT JOIN booking_platform.tickets ON tickets.booking_id = b.id
    LEFT JOIN booking_platform.payments p ON p.ticket_id = tickets.id;
COMMENT ON VIEW booking_platform.ClientBookingHistory IS
    'История бронирований клиентов: данные клиента, статус бронирования, маршрут, место, номер билета, стоимость и статус оплаты.';

SELECT * FROM booking_platform.ClientBookingHistory;


--Отобразить системный каталог
SELECT
    c.relname AS view_name,
    d.description
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_description d ON d.objoid = c.oid AND d.objsubid = 0
WHERE n.nspname = 'booking_platform' AND c.relkind = 'v';