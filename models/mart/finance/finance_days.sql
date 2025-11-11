WITH finance AS (
  SELECT 
    date AS date_date,
    COUNT(DISTINCT orders_id) AS nb_orders,
    ROUND(SUM(revenue),2) AS turnover,
    ROUND(SUM(operational_margin),2) AS operational_margin,
    ROUND(SUM(ship_cost) + SUM(shipping_fee) + SUM(logcost),2) AS shipping_total,
    ROUND(SUM(quantity),2) AS qty_sold,
    ROUND(SUM(ship_cost),2) AS ship_cost,
    ROUND(SUM(shipping_fee),2) AS shipping_fee,
    ROUND(SUM(logcost),2) AS log_cost,
    ROUND(SUM(margin),2) AS margin,
    ROUND(SUM(purchase_cost),2) AS purchase_cost
    
  FROM {{ ref("int_orders_operational") }}
  GROUP BY date
),

final AS (
  SELECT
    date_date,
    nb_orders,
    turnover,
    operational_margin,
    ROUND(SAFE_DIVIDE(turnover, nb_orders),2) AS avg_basket,
    shipping_total,
    qty_sold,
    ship_cost,
    shipping_fee,
    log_cost,
    margin,
    purchase_cost
    
  FROM finance
)

SELECT *
FROM final