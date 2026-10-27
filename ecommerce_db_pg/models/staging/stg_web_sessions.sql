with source_sessions as (

    select
        session_id,
        customer_id,
        session_date,
        device_type,
        landing_page,
        cart_created,
        checkout_started,
        order_completed,
        order_id_linked,
        abandonment_stage,
        checkout_failure_reason,
        utm_source,
        channel
    from {{ source('raw_ecommerce', 'Checkout_Sessions') }}

),

normalized_sessions as (

    select
        nullif(trim({{ dbt.safe_cast('session_id', dbt.type_string()) }}), '') as session_id,
        nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), '') as customer_id,
        {{ dbt.safe_cast('session_date', dbt.type_timestamp()) }} as session_timestamp,
        nullif(trim({{ dbt.safe_cast('device_type', dbt.type_string()) }}), '') as device_type,
        nullif(trim({{ dbt.safe_cast('landing_page', dbt.type_string()) }}), '') as landing_page,
        {{ dbt.safe_cast('cart_created', dbt.type_boolean()) }} as cart_created,
        {{ dbt.safe_cast('checkout_started', dbt.type_boolean()) }} as checkout_started,
        {{ dbt.safe_cast('order_completed', dbt.type_boolean()) }} as order_completed,
        nullif(trim({{ dbt.safe_cast('order_id_linked', dbt.type_string()) }}), '') as order_id,
        nullif(trim({{ dbt.safe_cast('abandonment_stage', dbt.type_string()) }}), '') as abandonment_stage,
        nullif(trim({{ dbt.safe_cast('checkout_failure_reason', dbt.type_string()) }}), '') as checkout_failure_reason,
        nullif(trim({{ dbt.safe_cast('utm_source', dbt.type_string()) }}), '') as utm_source,
        nullif(trim({{ dbt.safe_cast('channel', dbt.type_string()) }}), '') as channel
    from source_sessions

)

select *
from normalized_sessions
