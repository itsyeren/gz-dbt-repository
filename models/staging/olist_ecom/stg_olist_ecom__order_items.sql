with 

source as (

    select * from {{ source('olist_ecom', 'order_items') }}

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_date,
        price,
        freigth_value

    from source

)

select * from renamed