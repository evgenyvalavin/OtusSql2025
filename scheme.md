# Схема базы данных — Мультимодальный транспорт

---

## transport_types — Виды транспорта

| Поле        | Тип           | Ограничения       | Описание       |
|-------------|---------------|-------------------|----------------|
| id          | INTEGER       | PRIMARY KEY       | Идентификатор  |
| name        | VARCHAR(50)   | NOT NULL, UNIQUE  | Название       |
| description | TEXT          |                   | Описание       |

---

## carriers — Перевозчики

| Поле               | Тип           | Ограничения   | Описание            |
|--------------------|---------------|---------------|---------------------|
| id                 | INTEGER       | PRIMARY KEY   | Идентификатор       |
| name               | VARCHAR(200)  | NOT NULL      | Название компании   |
| transport_type_id  | INTEGER       | NOT NULL, FK  | Вид транспорта      |
| country            | VARCHAR(100)  |               | Страна регистрации  |
| contact_email      | VARCHAR(254)  |               | Email для связи     |
| contact_phone      | VARCHAR(30)   |               | Телефон для связи   |

---

## vehicles — Транспортные средства

| Поле               | Тип           | Ограничения           | Описание                             |
|--------------------|---------------|-----------------------|--------------------------------------|
| id                 | INTEGER       | PRIMARY KEY           | Идентификатор                        |
| carrier_id         | INTEGER       | NOT NULL, FK          | Перевозчик                           |
| transport_type_id  | INTEGER       | NOT NULL, FK          | Вид транспорта                       |
| model              | VARCHAR(100)  |                       | Модель (Boeing 737, РЖД Ласточка...) |
| registration_code  | VARCHAR(50)   | NOT NULL, UNIQUE      | Бортовой/регистрационный номер       |
| capacity           | SMALLINT      | NOT NULL, CHECK > 0   | Общее количество мест                |
| in_service_since   | DATE          |                       | Дата ввода в эксплуатацию            |

---

## stations — Станции, вокзалы, аэропорты

| Поле        | Тип                    | Ограничения     | Описание                                |
|-------------|------------------------|-----------------|-----------------------------------------|
| id          | INTEGER                | PRIMARY KEY     | Идентификатор                           |
| name        | VARCHAR(200)           | NOT NULL        | Название                                |
| city        | VARCHAR(100)           | NOT NULL        | Город                                   |
| country     | VARCHAR(100)           | NOT NULL        | Страна                                  |
| iata_code   | CHAR(3)                | UNIQUE          | IATA-код (для аэропортов)               |
| location    | GEOGRAPHY(POINT, 4326) | NOT NULL        | Координаты (lon, lat), WGS84            |
| timezone    | VARCHAR(50)            | NOT NULL        | Временная зона IANA (Europe/Moscow)     |

---

## routes — Маршруты

| Поле               | Тип           | Ограничения              | Описание               |
|--------------------|---------------|--------------------------|------------------------|
| id                 | INTEGER       | PRIMARY KEY              | Идентификатор          |
| carrier_id         | INTEGER       | NOT NULL, FK             | Перевозчик             |
| transport_type_id  | INTEGER       | NOT NULL, FK             | Вид транспорта         |
| origin_station_id  | INTEGER       | NOT NULL, FK             | Станция отправления    |
| dest_station_id    | INTEGER       | NOT NULL, FK             | Станция назначения     |
| route_code         | VARCHAR(20)   | NOT NULL, UNIQUE         | Номер маршрута/рейса   |
| is_active          | BOOLEAN       | NOT NULL, DEFAULT TRUE   | Маршрут активен        |

---

## trips — Рейсы

| Поле               | Тип                        | Ограничения                   | Описание                                 |
|--------------------|----------------------------|-------------------------------|------------------------------------------|
| id                 | INTEGER                    | PRIMARY KEY                   | Идентификатор                            |
| route_id           | INTEGER                    | NOT NULL, FK                  | Маршрут                                  |
| vehicle_id         | INTEGER                    | NOT NULL, FK                  | Транспортное средство                    |
| departure_at       | TIMESTAMP WITH TIME ZONE   | NOT NULL                      | Дата и время отправления                 |
| arrival_at         | TIMESTAMP WITH TIME ZONE   | NOT NULL                      | Дата и время прибытия                    |
| status             | trip_status                | NOT NULL, DEFAULT 'scheduled' | Статус (scheduled, cancelled, completed) |

---

## seat_classes — Классы мест

| Поле        | Тип           | Ограничения              | Описание                                   |
|-------------|---------------|--------------------------|--------------------------------------------|
| id          | INTEGER       | PRIMARY KEY              | Идентификатор                              |
| name        | VARCHAR(50)   | NOT NULL, UNIQUE         | Название (эконом, бизнес, купе, плацкарт)  |
| description | TEXT          |                          | Описание класса                            |

---

## seats — Места в транспортном средстве

| Поле            | Тип           | Ограничения              | Описание                        |
|-----------------|---------------|--------------------------|---------------------------------|
| id              | INTEGER       | PRIMARY KEY              | Идентификатор                   |
| vehicle_id      | INTEGER       | NOT NULL, FK             | Транспортное средство           |
| seat_class_id   | INTEGER       | NOT NULL, FK             | Класс места                     |
| seat_number     | VARCHAR(10)   | NOT NULL                 | Номер места (1A, 14, 023...)    |
| is_available    | BOOLEAN       | NOT NULL, DEFAULT TRUE   | Место доступно для продажи      |

---

## clients — Пассажиры

| Поле           | Тип           | Ограничения              | Описание           |
|----------------|---------------|--------------------------|--------------------|
| id             | INTEGER       | PRIMARY KEY              | Идентификатор      |
| first_name     | VARCHAR(100)  | NOT NULL                 | Имя                |
| last_name      | VARCHAR(100)  | NOT NULL                 | Фамилия            |
| birth_date     | DATE          | NOT NULL                 | Дата рождения      |
| passport_num   | VARCHAR(20)   |                          | Номер документа    |
| email          | VARCHAR(254)  | UNIQUE                   | Email              |
| phone          | VARCHAR(30)   |                          | Телефон            |
| registered_at  | TIMESTAMPTZ   | NOT NULL, DEFAULT NOW()  | Дата регистрации   |

---

## bookings — Бронирования

| Поле           | Тип             | Ограничения                 | Описание                                |
|----------------|-----------------|-----------------------------|-----------------------------------------|
| id             | INTEGER         | PRIMARY KEY                 | Идентификатор                           |
| client_id      | INTEGER         | NOT NULL, FK                | Пассажир                                |
| trip_id        | INTEGER         | NOT NULL, FK                | Рейс                                    |
| seat_id        | INTEGER         | NOT NULL, FK                | Место                                   |
| booked_at      | TIMESTAMPTZ     | NOT NULL, DEFAULT NOW()     | Дата и время бронирования               |
| status         | booking_status  | NOT NULL, DEFAULT 'pending' | Статус (pending, confirmed, cancelled)  |

---

## tickets — Оформленные билеты

| Поле           | Тип           | Ограничения              | Описание               |
|----------------|---------------|--------------------------|------------------------|
| id             | INTEGER       | PRIMARY KEY              | Идентификатор          |
| booking_id     | INTEGER       | NOT NULL, FK, UNIQUE     | Бронирование           |
| ticket_number  | VARCHAR(30)   | NOT NULL, UNIQUE         | Номер билета           |
| issued_at      | TIMESTAMPTZ   | NOT NULL, DEFAULT NOW()  | Дата и время выдачи    |
| total_price    | NUMERIC(12, 2)| NOT NULL                 | Итоговая стоимость     |
| currency       | CHAR(3)       | NOT NULL, DEFAULT 'RUB'  | Валюта (ISO 4217)      |
| is_returned    | BOOLEAN       | NOT NULL, DEFAULT FALSE  | Сдан/возвращён         |

---

## payments — Оплаты и возвраты

| Поле           | Тип             | Ограничения                 | Описание                                                |
|----------------|-----------------|-----------------------------|---------------------------------------------------------|
| id             | INTEGER         | PRIMARY KEY                 | Идентификатор                                           |
| ticket_id      | INTEGER         | NOT NULL, FK                | Билет                                                   |
| amount         | NUMERIC(12, 2)  | NOT NULL                    | Сумма (положительная — оплата, отрицательная — возврат) |
| currency       | CHAR(3)         | NOT NULL, DEFAULT 'RUB'     | Валюта                                                  |
| method         | VARCHAR(30)     | NOT NULL                    | Способ оплаты (card, cash, online)                      |
| status         | payment_status  | NOT NULL, DEFAULT 'pending' | Статус (pending, completed, failed, refunded)        |
| paid_at        | TIMESTAMPTZ     |                             | Дата и время успешной оплаты                            |
| created_at     | TIMESTAMPTZ     | NOT NULL, DEFAULT NOW()     | Дата создания записи                                    |
| external_ref   | VARCHAR(100)    |                             | Ссылка на внешнюю транзакцию                            |
