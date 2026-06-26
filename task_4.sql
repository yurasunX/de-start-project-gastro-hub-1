WITH pizza_items AS (
    SELECT
        r.cafe_name,
        p.key AS pizza_name
    FROM cafe.restaurants r
    CROSS JOIN LATERAL json_each_text((r.menu -> 'Пицца')::json) AS p(key, value)
    WHERE r.type = 'pizzeria'
),
pizza_count_by_restaurant AS (
    SELECT
        cafe_name,
        COUNT(*) AS pizza_count
    FROM pizza_items
    GROUP BY cafe_name
),
ranked_pizzerias AS (
    SELECT
        cafe_name,
        pizza_count,
        DENSE_RANK() OVER (
            ORDER BY pizza_count DESC
        ) AS rank_num
    FROM pizza_count_by_restaurant
)
SELECT
    cafe_name,
    pizza_count
FROM ranked_pizzerias
WHERE rank_num = 1
ORDER BY cafe_name;
