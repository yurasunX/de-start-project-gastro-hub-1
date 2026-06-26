DROP MATERIALIZED VIEW IF EXISTS cafe.yearly_avg_check_change;

CREATE MATERIALIZED VIEW cafe.yearly_avg_check_change AS
WITH yearly_avg_check AS (
    SELECT
        EXTRACT(YEAR FROM s."date")::int AS year,
        r.cafe_name,
        r.type,
        ROUND(AVG(s.avg_check), 2) AS avg_check_current_year
    FROM cafe.sales s
    JOIN cafe.restaurants r
        ON s.restaurant_uuid = r.restaurant_uuid
    WHERE EXTRACT(YEAR FROM s."date") <> 2023
    GROUP BY
        EXTRACT(YEAR FROM s."date")::int,
        r.restaurant_uuid,
        r.cafe_name,
        r.type
),
yearly_with_previous AS (
    SELECT
        year,
        cafe_name,
        type,
        avg_check_current_year,
        LAG(avg_check_current_year) OVER (
            PARTITION BY cafe_name
            ORDER BY year
        ) AS avg_check_previous_year
    FROM yearly_avg_check
)
SELECT
    year,
    cafe_name,
    type,
    avg_check_current_year,
    avg_check_previous_year,
    ROUND(
        (
            avg_check_current_year - avg_check_previous_year
        ) / avg_check_previous_year * 100,
        2
    ) AS avg_check_change_percent
FROM yearly_with_previous;
