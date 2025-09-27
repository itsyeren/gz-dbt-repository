WITH finance AS (
  SELECT 
    EXTRACT(DAY FROM date) AS date_day,
    COUNT(DISTINCT orders_id) AS nb_orders,
    ROUND(SUM(revenue),2) AS turnover,
    ROUND(SUM(operational_margin),2) AS operational_margin,
    ROUND(SUM(ship_cost) + SUM(shipping_fee) + SUM(logcost),2) AS shipping_total,
    ROUND(SUM(quantity),2) AS qty_sold
  FROM {{ ref("int_orders_operational") }}
  GROUP BY date
),

final AS (
  SELECT
    date_day,
    nb_orders,
    turnover,
    ROUND(SAFE_DIVIDE(turnover, nb_orders),2) AS avg_basket,
    operational_margin,
    shipping_total,
    qty_sold
  FROM finance
)

SELECT *
FROM final