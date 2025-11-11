with 

source as (

    select * from {{ source('olist_ecom', 'order_payment_info') }}

),

renamed as (

    select
        order_id,
        payment_type,
        payment_installments,
        payment_value

    from source

)

select * from renamed