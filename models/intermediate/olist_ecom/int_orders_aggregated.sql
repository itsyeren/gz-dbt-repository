{{ config(materialized='view') }}

WITH items AS (
  SELECT * FROM {{ ref('int_orders_items_enriched') }}
),
by_order AS (
  SELECT
    order_id,
    ANY_VALUE(customer_id)                         AS customer_id,
    ANY_VALUE(order_status)                        AS order_status,
    MIN(order_purchase_ts)                         AS order_purchase_ts,
    MAX(order_delivered_ts)                        AS order_delivered_ts,
    MAX(order_estimated_delivery_dt)               AS order_estimated_delivery_dt,
    COUNT(DISTINCT order_item_id)                  AS item_count,
    SUM(price)                                     AS order_merchandise,
    SUM(freight_value)                             AS order_freight,
    SUM(order_item_total)                          AS order_total
  FROM items
  GROUP BY order_id
),
pay AS (SELECT * FROM {{ ref('int_payments_by_order') }}),
rev AS (SELECT * FROM {{ ref('int_reviews_by_order') }})

SELECT
  b.order_id,
  b.customer_id,
  b.order_status,
  b.order_purchase_ts,
  b.order_delivered_ts,
  b.order_estimated_delivery_dt,

  -- KPIs / flags
  TIMESTAMP_DIFF(b.order_delivered_ts, b.order_purchase_ts, DAY) AS delivery_days,
  TIMESTAMP_DIFF(b.order_delivered_ts, TIMESTAMP(b.order_estimated_delivery_dt), DAY) AS shipping_delay,
  CASE WHEN b.order_delivered_ts IS NOT NULL
         AND b.order_estimated_delivery_dt IS NOT NULL
         AND b.order_delivered_ts <= TIMESTAMP(b.order_estimated_delivery_dt)
       THEN 1 ELSE 0 END AS delivered_on_time_flag,
  CASE WHEN b.order_status IN ('canceled','unavailable') THEN 1 ELSE 0 END AS canceled_flag,
  CASE WHEN b.order_status NOT IN ('delivered','canceled','unavailable') THEN 1 ELSE 0 END AS pending_flag,

  -- totals
  b.item_count,
  b.order_merchandise,
  b.order_freight,
  b.order_total,

  -- payments
  p.payment_total,
  p.max_installments,
  p.dominant_payment_type,

  -- reviews
  r.review_score_avg,
  r.total_reviews,
  r.five_star_count,
  r.low_score_count,
  r.review_response_days
FROM by_order b
LEFT JOIN pay p USING (order_id)
LEFT JOIN rev r USING (order_id)
