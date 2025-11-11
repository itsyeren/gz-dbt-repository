WITH pay AS (
    SELECT
        order_id,
        payment_type,
        CAST(payment_value AS float64)              AS payment_value,
        CAST(payment_installments AS int64)         AS payment_installments
    FROM {{ref("stg_olist_ecom__order_payment_info")}}
),

agg AS (
    SELECT
        order_id,
        SUM(payment_value)                                          AS payment_total,
        MAX(payment_installments)                                   AS max_installments,
        array_agg(struct(payment_type, payment_value)
            ORDER BY  payment_value DESC)[offset(0)].payment_type   AS dominant_payment_type
    FROM pay
    GROUP BY order_id
)   

SELECT *
FROM agg