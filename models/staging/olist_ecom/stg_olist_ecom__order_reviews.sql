with 

source as (

    select * from {{ source('olist_ecom', 'order_reviews') }}

),

renamed as (

    select
        review_id,
        order_id,
        review_score,
        review_creation_date,
        review_answer_date

    from source

)

select * from renamed