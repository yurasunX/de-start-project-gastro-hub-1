CREATE SCHEMA IF NOT EXISTS cafe;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE cafe.restaurant_type AS ENUM (
    'coffee_shop',
    'restaurant',
    'bar',
    'pizzeria'
);

CREATE TABLE cafe.restaurants (
    restaurant_uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cafe_name varchar NOT NULL,
    type cafe.restaurant_type NOT NULL,
    menu jsonb
);

CREATE TABLE cafe.managers (
    manager_uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    manager_name varchar NOT NULL,
    manager_phone varchar NOT NULL
);

CREATE TABLE cafe.restaurant_manager_work_dates (
    restaurant_uuid uuid NOT NULL,
    manager_uuid uuid NOT NULL,
    work_start_date date NOT NULL,
    work_end_date date NOT NULL,

    PRIMARY KEY (restaurant_uuid, manager_uuid),

    FOREIGN KEY (restaurant_uuid)
        REFERENCES cafe.restaurants (restaurant_uuid),

    FOREIGN KEY (manager_uuid)
        REFERENCES cafe.managers (manager_uuid)
);

CREATE TABLE cafe.sales (
    "date" date NOT NULL,
    restaurant_uuid uuid NOT NULL,
    avg_check numeric(6, 2) NOT NULL,

    PRIMARY KEY ("date", restaurant_uuid),

    FOREIGN KEY (restaurant_uuid)
        REFERENCES cafe.restaurants (restaurant_uuid)
);
