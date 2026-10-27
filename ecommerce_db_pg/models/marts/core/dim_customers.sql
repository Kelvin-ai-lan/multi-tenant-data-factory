with customers as (

    select
        customer_id,
        registration_timestamp,
        country_name,
        device_type,
        customer_segment,
        loyalty_program_member,
        premium_subscription,
        loyalty_points_balance,
        acquisition_source
    from {{ ref('stg_customers') }}

),

customer_order_metrics as (

    select
        customer_id,
        count(distinct order_id) as lifetime_transaction_count,
        sum(coalesce(gross_revenue_amount, 0)) as gross_lifetime_revenue_amount
    from {{ ref('stg_orders') }}
    where customer_id is not null
    group by customer_id

),

customer_support_metrics as (

    select
        customer_id,
        avg(csat_score) as average_csat_score
    from {{ ref('stg_customer_support') }}
    where customer_id is not null
    group by customer_id

),

customer_lifetime_value as (

    select
        customers.customer_id,
        customers.registration_timestamp,
        customers.country_name,
        customers.device_type,
        customers.customer_segment,
        customers.loyalty_program_member,
        customers.premium_subscription,
        customers.loyalty_points_balance,
        customers.acquisition_source,
        coalesce(customer_order_metrics.lifetime_transaction_count, 0) as lifetime_transaction_count,
        coalesce(customer_order_metrics.gross_lifetime_revenue_amount, 0) as gross_lifetime_revenue_amount,
        customer_support_metrics.average_csat_score
    from customers
    left join customer_order_metrics
        on customers.customer_id = customer_order_metrics.customer_id
    left join customer_support_metrics
        on customers.customer_id = customer_support_metrics.customer_id

)

select
    customer_id,
    registration_timestamp,
    country_name,
    device_type,
    customer_segment,
    loyalty_program_member,
    premium_subscription,
    loyalty_points_balance,
    acquisition_source,
    lifetime_transaction_count,
    gross_lifetime_revenue_amount,
    average_csat_score,
    case
        when lifetime_transaction_count >= 10 then 'gold'
        when lifetime_transaction_count >= 5 then 'silver'
        when lifetime_transaction_count >= 2 then 'bronze'
        else 'standard'
    end as customer_loyalty_tier
from customer_lifetime_value
