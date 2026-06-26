WITH menu_cte AS (
    SELECT
        r.cafe_name,
        'Пицца' AS dish_type,
        pizza.key AS pizza_name,
        pizza.value::int AS price
    FROM cafe.restaurants r
    CROSS JOIN LATERAL json_each_text((r.menu -> 'Пицца')::json) AS pizza(key, value)
    WHERE r.type = 'pizzeria'
),
menu_with_rank AS (
    SELECT
        cafe_name,
        dish_type,
        pizza_name,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY cafe_name
            ORDER BY price DESC
        ) AS price_rank
    FROM menu_cte
)
SELECT
    cafe_name,
    dish_type,
    pizza_name,
    price
FROM menu_with_rank
WHERE price_rank = 1
ORDER BY cafe_name;
