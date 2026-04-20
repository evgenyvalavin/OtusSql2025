-- CTE: routes_without_trips
-- Возвращает маршруты, для которых не создано ни одного рейса.
-- Используется для выявления «мёртвых» маршрутов в системе.
-- NOT EXISTS безопаснее, чем NOT IN: корректно работает даже если route_id содержит NULL.
WITH routes_without_trips AS (
    SELECT *
    FROM booking_platform.routes r
    WHERE NOT EXISTS (
        SELECT 1
        FROM booking_platform.trips t
        WHERE t.route_id = r.id
    )
)

SELECT * FROM routes_without_trips;