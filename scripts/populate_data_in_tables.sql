-- ============================================================
-- Seed data
-- Insert order respects foreign key dependencies
-- ============================================================

-- 1. transport_types
-- ids: 1=Flight, 2=Train, 3=Bus
INSERT INTO booking_platform.transport_types (name, description) VALUES
    ('Flight', 'Air travel by airplane'),
    ('Train',  'Rail travel by train'),
    ('Bus',    'Road travel by bus');

-- 2. seat_classes
-- ids: 1=Economy, 2=Business, 3=First Class
INSERT INTO booking_platform.seat_classes (name, description) VALUES
    ('Economy',     'Standard economy class seating'),
    ('Business',    'Business class with extra comfort'),
    ('First Class', 'Premium first class seating');

-- 3. stations
-- ids: 1=SVO, 2=DME, 3=LED, 4=AER, 5=Moscow Leningradsky, 6=SPb Moskovsky, 7=Moscow Bus, 8=KZN, 9=IST, 10=FRA, 11=CDG, 12=DXB
INSERT INTO booking_platform.stations (name, city, country, iata_code, location, timezone) VALUES
    ('Sheremetyevo International Airport',  'Moscow',           'Russia',  'SVO', ST_MakePoint(37.4146, 55.9726)::geography, 'Europe/Moscow'),
    ('Domodedovo International Airport',    'Moscow',           'Russia',  'DME', ST_MakePoint(37.9063, 55.4088)::geography, 'Europe/Moscow'),
    ('Pulkovo Airport',                     'Saint Petersburg', 'Russia',  'LED', ST_MakePoint(30.2625, 59.8003)::geography, 'Europe/Moscow'),
    ('Sochi International Airport',         'Sochi',            'Russia',  'AER', ST_MakePoint(39.9566, 43.4499)::geography, 'Europe/Moscow'),
    ('Moscow Leningradsky Railway Station', 'Moscow',           'Russia',  NULL,  ST_MakePoint(37.6559, 55.7762)::geography, 'Europe/Moscow'),
    ('Saint Petersburg Moskovsky Station',  'Saint Petersburg', 'Russia',  NULL,  ST_MakePoint(30.3606, 59.9274)::geography, 'Europe/Moscow'),
    ('Moscow Central Bus Terminal',         'Moscow',           'Russia',  NULL,  ST_MakePoint(37.6173, 55.7522)::geography, 'Europe/Moscow'),
    ('Kazan International Airport',         'Kazan',            'Russia',  'KZN', ST_MakePoint(49.2787, 55.6062)::geography, 'Europe/Moscow'),
    ('Istanbul Airport',                    'Istanbul',         'Turkey',  'IST', ST_MakePoint(28.7519, 41.2753)::geography, 'Europe/Istanbul'),
    ('Frankfurt Airport',                   'Frankfurt',        'Germany', 'FRA', ST_MakePoint( 8.5706, 50.0379)::geography, 'Europe/Berlin'),
    ('Paris Charles de Gaulle Airport',     'Paris',            'France',  'CDG', ST_MakePoint( 2.5479, 49.0097)::geography, 'Europe/Paris'),
    ('Dubai International Airport',         'Dubai',            'UAE',     'DXB', ST_MakePoint(55.3644, 25.2532)::geography, 'Asia/Dubai');

-- 4. carries
-- ids: 1=Aeroflot, 2=S7, 3=Russian Railways, 4=Avtodor, 5=Turkish Airlines, 6=Lufthansa, 7=Air France, 8=Emirates
INSERT INTO booking_platform.carries (name, country, contact_email, contact_phone) VALUES
    ('Aeroflot',          'Russia',  'carrier1@example.com',   '+7000000010'),
    ('S7 Airlines',       'Russia',  'carrier2@example.com',   '+7000000020'),
    ('Russian Railways',  'Russia',  'carrier3@example.com',   '+7000000030'),
    ('Avtodor Bus Lines', 'Russia',  'carrier4@example.com',   '+7000000040'),
    ('Turkish Airlines',  'Turkey',  'turkish@example.com',    '+90000000010'),
    ('Lufthansa',         'Germany', 'lufthansa@example.com',  '+49000000010'),
    ('Air France',        'France',  'airfrance@example.com',  '+33000000010'),
    ('Emirates',          'UAE',     'emirates@example.com',   '+97100000010');

-- 5. vehicles
-- ids: 1-2=Aeroflot aircraft, 3=S7 aircraft, 4-5=RZD trains, 6-7=Avtodor buses, 8=Turkish B777, 9=Lufthansa A350, 10=Air France B787, 11=Emirates A380
INSERT INTO booking_platform.vehicles (carrier_id, transport_type_id, model, registration_code, capacity, in_service_since) VALUES
    (1, 1, 'Boeing 737-800',          'RA-73012',    189, '2018-03-15'),
    (1, 1, 'Airbus A320',             'RA-89001',    165, '2019-06-20'),
    (2, 1, 'Boeing 737 MAX 8',        'RA-73456',    178, '2021-11-01'),
    (3, 2, 'Sapsan High-Speed Train', 'RZD-SAP-001', 604, '2010-12-17'),
    (3, 2, 'Lastochka EMU',           'RZD-LAS-002', 450, '2014-05-10'),
    (4, 3, 'Mercedes-Benz Tourismo',  'A123BC77',     50, '2020-09-01'),
    (4, 3, 'Setra S516 HDH',          'B456DE77',     55, '2022-02-14'),
    (5, 1, 'Boeing 777-300ER',        'TC-JJJ',      396, '2017-04-10'),
    (6, 1, 'Airbus A350-900',         'D-AIXB',      293, '2019-08-22'),
    (7, 1, 'Boeing 787-9',            'F-HRBA',      279, '2020-03-05'),
    (8, 1, 'Airbus A380-800',         'A6-EDE',      517, '2015-11-30');

-- 6. routes
-- ids: 1=SU-101, 2=SU-202, 3=S7-301, 4=RZD-001, 5=AVT-001, 6=TK-414, 7=LH-1457, 8=AF-1645, 9=EK-133
INSERT INTO booking_platform.routes (carrier_id, origin_station_id, dest_station_id, route_code, is_active) VALUES
    (1, 1, 3,  'SU-101',  TRUE),  -- Aeroflot:       SVO -> LED
    (1, 1, 4,  'SU-202',  TRUE),  -- Aeroflot:       SVO -> AER
    (2, 2, 8,  'S7-301',  TRUE),  -- S7:             DME -> KZN
    (3, 5, 6,  'RZD-001', TRUE),  -- RZD:            Moscow Leningradsky -> SPb Moskovsky
    (4, 7, 6,  'AVT-001', TRUE),  -- Avtodor:        Moscow Bus Terminal -> SPb Moskovsky
    (5, 1, 9,  'TK-414',  TRUE),  -- Turkish:        SVO -> IST
    (6, 1, 10, 'LH-1457', TRUE),  -- Lufthansa:      SVO -> FRA
    (7, 3, 11, 'AF-1645', TRUE),  -- Air France:     LED -> CDG
    (8, 2, 12, 'EK-133',  TRUE);  -- Emirates:       DME -> DXB

-- 7. trips
INSERT INTO booking_platform.trips (route_id, vehicle_id, departure_at, arriaval_at, status) VALUES
    (1, 1,  '2026-05-01 06:00:00+03', '2026-05-01 07:25:00+03', 'scheduled'),  -- Aeroflot B737,   SVO->LED
    (1, 2,  '2026-05-02 14:30:00+03', '2026-05-02 15:55:00+03', 'scheduled'),  -- Aeroflot A320,   SVO->LED
    (2, 1,  '2026-05-03 09:00:00+03', '2026-05-03 12:10:00+03', 'scheduled'),  -- Aeroflot B737,   SVO->AER
    (3, 3,  '2026-05-01 11:00:00+03', '2026-05-01 13:30:00+03', 'scheduled'),  -- S7,              DME->KZN
    (4, 4,  '2026-05-01 07:00:00+03', '2026-05-01 11:00:00+03', 'scheduled'),  -- Sapsan,          MSK->SPb
    (5, 6,  '2026-05-01 08:00:00+03', '2026-05-01 16:00:00+03', 'scheduled'),  -- Bus,             MSK->SPb
    (6, 8,  '2026-05-05 10:30:00+03', '2026-05-05 13:45:00+03', 'scheduled'),  -- Turkish B777,    SVO->IST
    (7, 9,  '2026-05-06 09:00:00+03', '2026-05-06 11:40:00+02', 'scheduled'),  -- Lufthansa A350,  SVO->FRA
    (8, 10, '2026-05-07 14:00:00+03', '2026-05-07 17:00:00+02', 'scheduled'),  -- Air France B787, LED->CDG
    (9, 11, '2026-05-08 23:00:00+03', '2026-05-09 05:30:00+04', 'scheduled');  -- Emirates A380,   DME->DXB

-- 8. seats
-- Vehicle 1 (Boeing 737, Aeroflot) — seat ids 1-10
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (1, 3, '1A',  TRUE), (1, 3, '1B',  TRUE), (1, 3, '1C',  TRUE),  -- First Class
    (1, 2, '5A',  TRUE), (1, 2, '5B',  TRUE), (1, 2, '5C',  TRUE),  -- Business
    (1, 1, '20A', TRUE), (1, 1, '20B', TRUE), (1, 1, '20C', TRUE), (1, 1, '20D', TRUE);  -- Economy

-- Vehicle 2 (Airbus A320, Aeroflot) — seat ids 11-18
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (2, 2, '1A',  TRUE), (2, 2, '1B',  TRUE), (2, 2, '1C',  TRUE),  -- Business
    (2, 1, '15A', TRUE), (2, 1, '15B', TRUE), (2, 1, '15C', TRUE),  -- Economy
    (2, 1, '25A', TRUE), (2, 1, '25B', TRUE);

-- Vehicle 3 (Boeing 737 MAX, S7) — seat ids 19-24
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (3, 2, '2A',  TRUE), (3, 2, '2B',  TRUE),                        -- Business
    (3, 1, '10A', TRUE), (3, 1, '10B', TRUE), (3, 1, '10C', TRUE), (3, 1, '10D', TRUE);  -- Economy

-- Vehicle 4 (Sapsan, RZD) — seat ids 25-30
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (4, 2, '1', TRUE), (4, 2, '2', TRUE), (4, 2, '3', TRUE),         -- Business
    (4, 1, '50', TRUE), (4, 1, '51', TRUE), (4, 1, '52', TRUE);      -- Economy

-- Vehicle 5 (Lastochka, RZD) — seat ids 31-34
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (5, 1, '1', TRUE), (5, 1, '2', TRUE), (5, 1, '3', TRUE), (5, 1, '4', TRUE);

-- Vehicle 6 (Mercedes Tourismo, Avtodor) — seat ids 35-38
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (6, 1, '1', TRUE), (6, 1, '2', TRUE), (6, 1, '3', TRUE), (6, 1, '4', TRUE);

-- Vehicle 7 (Setra S516, Avtodor) — seat ids 39-42
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (7, 1, '1', TRUE), (7, 1, '2', TRUE), (7, 1, '3', TRUE), (7, 1, '4', TRUE);

-- Vehicle 8 (Turkish B777) — seat ids 43-48
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (8, 3, '1A',  TRUE), (8, 3, '1B',  TRUE),                        -- First Class
    (8, 2, '8A',  TRUE), (8, 2, '8B',  TRUE),                        -- Business
    (8, 1, '30A', TRUE), (8, 1, '30B', TRUE);                        -- Economy

-- Vehicle 9 (Lufthansa A350) — seat ids 49-54
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (9, 3, '2A',  TRUE), (9, 3, '2B',  TRUE),                        -- First Class
    (9, 2, '7A',  TRUE), (9, 2, '7B',  TRUE),                        -- Business
    (9, 1, '25A', TRUE), (9, 1, '25B', TRUE);                        -- Economy

-- Vehicle 10 (Air France B787) — seat ids 55-60
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (10, 2, '3A',  TRUE), (10, 2, '3B',  TRUE),                      -- Business
    (10, 1, '20A', TRUE), (10, 1, '20B', TRUE), (10, 1, '20C', TRUE), (10, 1, '20D', TRUE);  -- Economy

-- Vehicle 11 (Emirates A380) — seat ids 61-66
INSERT INTO booking_platform.seats (vehicle_id, seat_class_id, seat_number, is_available) VALUES
    (11, 3, '1A',  TRUE), (11, 3, '1B',  TRUE),                      -- First Class
    (11, 2, '9A',  TRUE), (11, 2, '9B',  TRUE),                      -- Business
    (11, 1, '35A', TRUE), (11, 1, '35B', TRUE);                      -- Economy

-- 9. clients
INSERT INTO booking_platform.clients (first_name, last_name, birth_date, passport_num, email, phone, registered_at) VALUES
    ('Ivan',   'Petrov',     '1990-04-12', '0000 000001', 'client1@example.com', '+0000000001', '2024-01-10 09:00:00+03'),
    ('Maria',  'Ivanova',    '1985-07-23', '0000 000002', 'client2@example.com', '+0000000002', '2024-02-15 10:30:00+03'),
    ('Alexei', 'Sidorov',    '1978-11-05', '0000 000003', 'client3@example.com', '+0000000003', '2024-03-01 14:00:00+03'),
    ('Olga',   'Kuznetsova', '1995-02-28', '0000 000004', 'client4@example.com', '+0000000004', '2024-04-20 11:15:00+03'),
    ('Dmitry', 'Volkov',     '2000-09-15', '0000 000005', 'client5@example.com', '+0000000005', '2024-05-05 08:45:00+03'),
    ('John',   'Smith',      '1988-06-14', 'GB00000001',  'client6@example.com', '+44000000006', '2025-01-12 08:00:00+00'),
    ('Fatima', 'Al-Rashid',  '1993-03-21', 'AE00000002',  'client7@example.com', '+97100000007', '2025-02-20 10:00:00+04'),
    ('Klaus',  'Weber',      '1975-09-30', 'DE00000003',  'client8@example.com', '+49000000008', '2025-03-05 09:30:00+01'),
    ('Sophie', 'Dupont',     '1991-12-08', 'FR00000004',  'client9@example.com', '+33000000009', '2025-04-18 11:45:00+02');

-- 10. bookings
INSERT INTO booking_platform.bookings (client_id, trip_id, seat_id, booked_at, status) VALUES
    (1, 1,  1,  '2026-04-01 10:00:00+03', 'confirmed'),  -- Ivan,   Trip 1  (B737 SVO->LED),      seat 1A  First Class
    (2, 1,  4,  '2026-04-02 11:00:00+03', 'confirmed'),  -- Maria,  Trip 1  (B737 SVO->LED),      seat 5A  Business
    (3, 1,  7,  '2026-04-03 09:30:00+03', 'confirmed'),  -- Alexei, Trip 1  (B737 SVO->LED),      seat 20A Economy
    (4, 2,  11, '2026-04-05 14:00:00+03', 'pending'),    -- Olga,   Trip 2  (A320 SVO->LED),      seat 1A  Business
    (5, 4,  19, '2026-04-06 16:00:00+03', 'confirmed'),  -- Dmitry, Trip 4  (S7 DME->KZN),        seat 2A  Business
    (1, 5,  25, '2026-04-07 08:00:00+03', 'confirmed'),  -- Ivan,   Trip 5  (Sapsan MSK->SPb),    seat 1   Business
    (3, 6,  35, '2026-04-08 12:00:00+03', 'cancelled'),  -- Alexei, Trip 6  (Bus MSK->SPb),       seat 1   Economy
    (6, 7,  45, '2026-04-10 09:00:00+00', 'confirmed'),  -- John,   Trip 7  (TK SVO->IST),        seat 8A  Business
    (7, 10, 61, '2026-04-11 12:00:00+04', 'confirmed'),  -- Fatima, Trip 10 (EK DME->DXB),        seat 1A  First Class
    (8, 8,  51, '2026-04-12 14:00:00+01', 'confirmed'),  -- Klaus,  Trip 8  (LH SVO->FRA),        seat 7A  Business
    (9, 9,  55, '2026-04-13 10:30:00+02', 'pending');    -- Sophie, Trip 9  (AF LED->CDG),        seat 3A  Business

-- 11. tickets
INSERT INTO booking_platform.tickets (booking_id, ticket_number, issued_at, total_price, currency, is_returned) VALUES
    (1,  'TKT-2026-000001', '2026-04-01 10:05:00+03', 15000.00, 'RUB', FALSE),
    (2,  'TKT-2026-000002', '2026-04-02 11:05:00+03',  8500.00, 'RUB', FALSE),
    (3,  'TKT-2026-000003', '2026-04-03 09:35:00+03',  5200.00, 'RUB', FALSE),
    (4,  'TKT-2026-000004', '2026-04-05 14:05:00+03',  7800.00, 'RUB', FALSE),
    (5,  'TKT-2026-000005', '2026-04-06 16:05:00+03',  9100.00, 'RUB', FALSE),
    (6,  'TKT-2026-000006', '2026-04-07 08:05:00+03',  4300.00, 'RUB', FALSE),
    (8,  'TKT-2026-000007', '2026-04-10 09:05:00+00',   320.00, 'EUR', FALSE),
    (9,  'TKT-2026-000008', '2026-04-11 12:05:00+04',   850.00, 'USD', FALSE),
    (10, 'TKT-2026-000009', '2026-04-12 14:05:00+01',   480.00, 'EUR', FALSE),
    (11, 'TKT-2026-000010', '2026-04-13 10:35:00+02',   290.00, 'EUR', FALSE);

-- 12. payments
INSERT INTO booking_platform.payments (ticket_id, amount, currency, mathod, status, paid_at, created_at, external_ref) VALUES
    (1,  15000.00, 'RUB', 'credit_card', 'completed', '2026-04-01 10:10:00+03', '2026-04-01 10:05:00+03', 'EXT-REF-001'),
    (2,   8500.00, 'RUB', 'credit_card', 'completed', '2026-04-02 11:10:00+03', '2026-04-02 11:05:00+03', 'EXT-REF-002'),
    (3,   5200.00, 'RUB', 'sbp',         'completed', '2026-04-03 09:40:00+03', '2026-04-03 09:35:00+03', 'EXT-REF-003'),
    (4,   7800.00, 'RUB', 'credit_card', 'pending',   NULL,                     '2026-04-05 14:05:00+03', NULL),
    (5,   9100.00, 'RUB', 'debit_card',  'completed', '2026-04-06 16:12:00+03', '2026-04-06 16:05:00+03', 'EXT-REF-005'),
    (6,   4300.00, 'RUB', 'sbp',         'completed', '2026-04-07 08:08:00+03', '2026-04-07 08:05:00+03', 'EXT-REF-006'),
    (7,    320.00, 'EUR', 'credit_card', 'completed', '2026-04-10 09:12:00+00', '2026-04-10 09:05:00+00', 'EXT-REF-007'),
    (8,    850.00, 'USD', 'credit_card', 'completed', '2026-04-11 12:10:00+04', '2026-04-11 12:05:00+04', 'EXT-REF-008'),
    (9,    480.00, 'EUR', 'debit_card',  'completed', '2026-04-12 14:09:00+01', '2026-04-12 14:05:00+01', 'EXT-REF-009'),
    (10,   290.00, 'EUR', 'credit_card', 'pending',   NULL,                     '2026-04-13 10:35:00+02', NULL);