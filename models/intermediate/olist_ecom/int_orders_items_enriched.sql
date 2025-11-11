{{ config(materialized='view') }}

{# --- Items'ta freight kolonu farklı isimde olabilir: autodetect --- #}
{% set items_cols = adapter.get_columns_in_relation(ref('stg_olist_ecom__order_items')) %}
{% set items_names = items_cols | map(attribute='name') | map('lower') | list %}

{% if 'freight_value' in items_names %}
  {% set freight_col = 'freight_value' %}
{% elif 'item_freight' in items_names %}
  {% set freight_col = 'item_freight' %}
{% elif 'freight' in items_names %}
  {% set freight_col = 'freight' %}
{% elif 'shipping_freight' in items_names %}
  {% set freight_col = 'shipping_freight' %}
{% else %}
  {% set freight_col = None %}
{% endif %}

WITH orders AS (
  SELECT * FROM {{ ref('stg_olist_ecom__orders') }}
),
items AS (
  SELECT * FROM {{ ref('stg_olist_ecom__order_items') }}
),
products AS (
  SELECT product_id, product_category_name
  FROM {{ ref('stg_olist_ecom__products') }}
),
sellers AS (
  SELECT seller_id, seller_city, seller_state
  FROM {{ ref('stg_olist_ecom__sellers') }}
)

SELECT
  i.order_id,
  i.order_item_id,
  o.customer_id,
  o.order_status,

  -- Orders: senin staging şemanla birebir
  TIMESTAMP(o.order_purchase_date)           AS order_purchase_ts,
  TIMESTAMP(o.order_delivered_customer_date) AS order_delivered_ts,
  DATE(o.order_estimated_delivery_date)      AS order_estimated_delivery_dt,

  p.product_category_name,
  s.seller_city,
  s.seller_state,

  SAFE_CAST(i.price AS FLOAT64) AS price,

  {% if freight_col %}
    SAFE_CAST(i.{{ freight_col }} AS FLOAT64) AS freight_value,
    SAFE_CAST(i.price AS FLOAT64)
    + SAFE_CAST(i.{{ freight_col }} AS FLOAT64) AS order_item_total
  {% else %}
    CAST(NULL AS FLOAT64) AS freight_value,
    SAFE_CAST(i.price AS FLOAT64) AS order_item_total
  {% endif %}

FROM items i
LEFT JOIN orders   o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN sellers  s USING (seller_id)
