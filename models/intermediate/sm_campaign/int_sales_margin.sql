WITH sales AS (
  SELECT
    orders_id,
    date_date,
    products_id,
    revenue,
    quantity
  FROM {{ ref('stg_raw__sales') }}
),
prod AS (
  SELECT
    products_id,                   -- align join key
    CAST(purchase_price AS FLOAT64) AS purchase_price
  FROM {{ ref('stg_raw__product') }}
),
joined AS (
  SELECT
    s.orders_id,
    s.products_id,
    s.date_date,
    s.revenue,
    s.quantity,
    p.purchase_price,
    (s.quantity * p.purchase_price) AS purchase_cost
  FROM sales s
  LEFT JOIN prod p USING (products_id)
)
SELECT
  date_date,
  orders_id,
  products_id,
  revenue,
  quantity,
  purchase_price,
  purchase_cost,
  ROUND((revenue - purchase_cost),2) AS margin,
  ROUND(SAFE_DIVIDE(revenue - purchase_cost, NULLIF(revenue, 0)),2) AS margin_percent
FROM joined