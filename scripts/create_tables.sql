--DROP SCHEMA IF EXISTS booking_platform CASCADE;

CREATE SCHEMA booking_platform;

CREATE TABLE booking_platform.transport_types(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE booking_platform.carries(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    country VARCHAR(100),
    contact_email VARCHAR(254),
    contact_phone VARCHAR(30)
);

CREATE TABLE booking_platform.vehicles(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    carrier_id INT NOT NULL REFERENCES booking_platform.carries(id),
    transport_type_id INT NOT NULL REFERENCES booking_platform.transport_types(id),
    model VARCHAR(100) NOT NULL,
    registration_code VARCHAR(50) NOT NULL UNIQUE,
    capacity SMALLINT NOT NULL CHECK (capacity > 0),
    in_service_since DATE
);

CREATE TABLE booking_platform.stations(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    iata_code CHAR(3) UNIQUE,
    location GEOGRAPHY(POINT, 4326),
    timezone VARCHAR(50)
);

CREATE TABLE booking_platform.routes(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    carrier_id INT NOT NULL REFERENCES booking_platform.carries(id),
    origin_station_id INT NOT NULL REFERENCES booking_platform.stations(id),
    dest_station_id INT NOT NULL REFERENCES booking_platform.stations(id),
    route_code VARCHAR(20) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TYPE booking_platform.trip_status AS ENUM ('scheduled', 'cancelled', 'completed');

CREATE TABLE booking_platform.trips(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_id INT NOT NULL REFERENCES booking_platform.routes(id),
    vehicle_id INT NOT NULL REFERENCES booking_platform.vehicles(id),
    departure_at TIMESTAMPTZ NOT NULL,
    arriaval_at TIMESTAMPTZ NOT NULL,
    status booking_platform.trip_status NOT NULL DEFAULT 'scheduled'
);

CREATE TABLE booking_platform.seat_classes(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE booking_platform.seats(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES booking_platform.vehicles(id),
    seat_class_id INT NOT NULL REFERENCES booking_platform.seat_classes(id),
    seat_number VARCHAR(10) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE booking_platform.clients(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    passport_num VARCHAR(20),
    email VARCHAR(254) UNIQUE,
    phone VARCHAR(30) UNIQUE,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE booking_platform.booking_status AS ENUM ('pending', 'confirmed', 'cancelled');

CREATE TABLE booking_platform.bookings(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id INT NOT NULL REFERENCES booking_platform.clients(id),
    trip_id INT NOT NULL REFERENCES booking_platform.trips(id),
    seat_id INT NOT NULL REFERENCES booking_platform.seats(id),
    booked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status booking_platform.booking_status NOT NULL DEFAULT 'pending'
);

CREATE UNIQUE INDEX bookings_one_active_per_trip_seat_idx
    ON booking_platform.bookings (trip_id, seat_id)
    WHERE status <> 'cancelled';

CREATE TABLE booking_platform.tickets(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES booking_platform.bookings(id),
    ticket_number VARCHAR(30) NOT NULL UNIQUE,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_price NUMERIC(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'RUB',
    is_returned BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TYPE booking_platform.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

CREATE TABLE booking_platform.payments(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id INT NOT NULL REFERENCES booking_platform.tickets(id),
    amount NUMERIC(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'RUB',
    mathod VARCHAR(30) NOT NULL,
    status booking_platform.payment_status NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    external_ref VARCHAR(100)
);
