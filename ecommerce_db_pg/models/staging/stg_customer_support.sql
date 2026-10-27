with source_customer_experience as (

    select
        order_id,
        customer_id,
        csat_score,
        nps_rating,
        support_ticket_theme,
        ticket_resolution_hours,
        delivery_satisfaction_rating
    from {{ source('raw_ecommerce', 'Customer_Experience') }}

),

normalized_customer_experience as (

    select
        nullif(trim({{ dbt.safe_cast('order_id', dbt.type_string()) }}), '') as order_id,
        nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), '') as customer_id,
        {{ dbt.safe_cast('csat_score', dbt.type_numeric()) }} as csat_score,
        {{ dbt.safe_cast('nps_rating', dbt.type_numeric()) }} as nps_score,
        nullif(trim({{ dbt.safe_cast('support_ticket_theme', dbt.type_string()) }}), '') as support_ticket_theme,
        {{ dbt.safe_cast('ticket_resolution_hours', dbt.type_numeric()) }} as ticket_resolution_hours,
        {{ dbt.safe_cast('delivery_satisfaction_rating', dbt.type_numeric()) }} as delivery_satisfaction_score
    from source_customer_experience

)

select *
from normalized_customer_experience
