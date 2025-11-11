SELECT 
    EXTRACT(MONTH FROM date_date) AS datemonth,
    ads_margin,
    average_basket,
    operational_margin,
    ads_cost,
    ads_impression,
    ads_clicks,
    qty_sold,
    revenue,
    purchase_cost,
    margin,
    shipping_fee,
    ship_cost,
    log_cost

FROM {{ref("finance_campaigns_day")}}
ORDER BY datemonth DESC