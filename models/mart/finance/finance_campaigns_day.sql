SELECT 
    date_date,
    ads_cost,
    ads_impression,
    ads_clicks,
    ROUND((operational_margin - ads_cost),2) AS ads_margin,
    avg_basket AS average_basket,
    operational_margin,
    qty_sold,
    turnover AS revenue,
    margin,
    purchase_cost,
    ship_cost,
    shipping_fee,
    log_cost

FROM {{ref("int_campaigns_day")}}
FULL OUTER JOIN {{ref("finance_days")}}
    USING (date_date)
ORDER BY date_date DESC