CREATE OR REPLACE VIEW cafe.top_3_restaurants_by_avg_check AS
WITH restaurant_avg_check AS (
    SELECT
        r.cafe_name,
        r.type,
        ROUND(AVG(s.avg_check), 2) AS avg_check
    FROM cafe.sales s
    JOIN cafe.restaurants r
        ON s.restaurant_uuid = r.restaurant_uuid
    GROUP BY
        r.restaurant_uuid,
        r.cafe_name,
        r.type
),
ranked_restaurants AS (
    SELECT
        cafe_name,
        type,
        avg_check,
        ROW_NUMBER() OVER (
            PARTITION BY type
            ORDER BY avg_check DESC
        ) AS row_number
    FROM restaurant_avg_check
)
SELECT
    cafe_name,
    type,
    avg_check
FROM ranked_restaurants
WHERE row_number <= 3;
