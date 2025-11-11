with 

source as (

    select * from {{ source('olist_ecom', 'order_KPIs_by_type') }}

),

renamed as (

    select
        payment_type,
        number_of_payments,
        revenue,
        avg_payment_value,
        max_payment_sequential,
        max_installments,
        revenue_share_pct

    from source

)

select * from renamed