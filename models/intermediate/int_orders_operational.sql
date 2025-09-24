WITH sales_d AS (
    SELECT 
        orders_id,
        date_date,
        margin
    FROM {{ ref('int_sales_margin') }}
),

ship AS (
    SELECT
        orders_id,
        shipping_fee,
        logcost,
        CAST(ship_cost AS FLOAT64) AS ship_cost
    FROM {{ ref('stg_raw__ship') }}
),

joined AS (
    SELECT
        d.orders_id,
        d.date_date,
        d.margin,
        s.shipping_fee,
        s.logcost,
        s.ship_cost,
        ROUND((d.margin - (s.shipping_fee + s.logcost + s.ship_cost)),2) AS operational_margin
    FROM sales_d d 
    LEFT JOIN ship s USING (orders_id)
)

SELECT 
    orders_id,
    date_date,
    operational_margin,
    shipping_fee,
    logcost,
    ship_cost
FROM joined
GROUP BY orders_id,date_date
ORDER BY orders_id DESC