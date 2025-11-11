with 

source as (

    select * from {{ source('olist_ecom', 'order_KPIs') }}

),

renamed as (

    select
        order_id,
        distinct_products,
        order_subtotal,
        order_freight,
        order_total,
        avg_item_price

    from source

)

select * from renamed