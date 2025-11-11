with r as (
  select
    order_id,
    cast(review_score as int64)             as review_score,
    cast(review_creation_date as timestamp) as review_creation_ts,
    cast(review_answer_date   as timestamp) as review_answer_ts
  from {{ ref('stg_olist_ecom__order_reviews') }}
)

select
  order_id,
  avg(review_score)                                          as review_score_avg,
  count(*)                                                   as total_reviews,
  countif(review_score = 5)                                  as five_star_count,
  countif(review_score <= 2)                                 as low_score_count,
  min(review_creation_ts)                                    as review_creation_ts,
  min(review_answer_ts)                                      as review_answer_ts,
  timestamp_diff(min(review_answer_ts), min(review_creation_ts), day) as review_response_days
from r
group by order_id