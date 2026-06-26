BEGIN;

-- Блокируем только строки заведений, где в меню есть капучино.
-- FOR UPDATE запрещает другим транзакциям изменять эти строки
-- до завершения текущей транзакции.
-- При этом заведения, где капучино нет, не блокируются:
-- их меню остаётся доступным для чтения и изменения.

WITH locked_restaurants AS (
    SELECT
        restaurant_uuid
    FROM cafe.restaurants
    WHERE menu -> 'Кофе' ? 'Капучино'
    FOR UPDATE
),
new_prices AS (
    SELECT
        r.restaurant_uuid,
        ROUND(((r.menu -> 'Кофе' ->> 'Капучино')::numeric * 1.2), 0)::int AS new_cappuccino_price
    FROM cafe.restaurants r
    JOIN locked_restaurants lr
        ON r.restaurant_uuid = lr.restaurant_uuid
)
UPDATE cafe.restaurants r
SET menu = jsonb_set(
    r.menu,
    '{Кофе,Капучино}',
    to_jsonb(np.new_cappuccino_price),
    false
)
FROM new_prices np
WHERE r.restaurant_uuid = np.restaurant_uuid;

COMMIT;
