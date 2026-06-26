INSERT INTO cafe.restaurants (
    cafe_name,
    type,
    menu
)
SELECT DISTINCT
    s.cafe_name,
    s.type::cafe.restaurant_type,
    m.menu
FROM raw_data.sales s
LEFT JOIN raw_data.menu m
    ON s.cafe_name = m.cafe_name;

INSERT INTO cafe.managers (
    manager_name,
    manager_phone
)
SELECT DISTINCT
    manager,
    manager_phone
FROM raw_data.sales;

INSERT INTO cafe.restaurant_manager_work_dates (
    restaurant_uuid,
    manager_uuid,
    work_start_date,
    work_end_date
)
SELECT
    r.restaurant_uuid,
    m.manager_uuid,
    MIN(s.report_date) AS work_start_date,
    MAX(s.report_date) AS work_end_date
FROM raw_data.sales s
JOIN cafe.restaurants r
    ON s.cafe_name = r.cafe_name
JOIN cafe.managers m
    ON s.manager = m.manager_name
   AND s.manager_phone = m.manager_phone
GROUP BY
    r.restaurant_uuid,
    m.manager_uuid;

INSERT INTO cafe.sales (
    "date",
    restaurant_uuid,
    avg_check
)
SELECT
    s.report_date AS "date",
    r.restaurant_uuid,
    s.avg_check
FROM raw_data.sales s
JOIN cafe.restaurants r
    ON s.cafe_name = r.cafe_name;
