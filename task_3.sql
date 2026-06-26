SELECT
    r.cafe_name,
    COUNT(w.manager_uuid) - 1 AS manager_change_count
FROM cafe.restaurant_manager_work_dates w
JOIN cafe.restaurants r
    ON w.restaurant_uuid = r.restaurant_uuid
GROUP BY
    r.restaurant_uuid,
    r.cafe_name
ORDER BY
    manager_change_count DESC,
    r.cafe_name
LIMIT 3;
