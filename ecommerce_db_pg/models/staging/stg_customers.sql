with source_customers as (

    select
        customer_id,
        customer_id_original,
        registration_date,
        customer_country,
        device_type,
        customer_segment,
        loyalty_program_member,
        premium_subscription,
        loyalty_points_balance,
        acquisition_source
    from {{ source('raw_ecommerce', 'Customers_v2') }}

),

normalized_customers as (

    select
        coalesce(
            nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), ''),
            nullif(trim({{ dbt.safe_cast('customer_id_original', dbt.type_string()) }}), '')
        ) as customer_id,
        {{ dbt.safe_cast('registration_date', dbt.type_timestamp()) }} as registration_timestamp,
        nullif(trim({{ dbt.safe_cast('customer_country', dbt.type_string()) }}), '') as country_name,
        nullif(trim({{ dbt.safe_cast('device_type', dbt.type_string()) }}), '') as device_type,
        nullif(trim({{ dbt.safe_cast('customer_segment', dbt.type_string()) }}), '') as customer_segment,
        {{ dbt.safe_cast('loyalty_program_member', dbt.type_boolean()) }} as loyalty_program_member,
        {{ dbt.safe_cast('premium_subscription', dbt.type_boolean()) }} as premium_subscription,
        {{ dbt.safe_cast('loyalty_points_balance', dbt.type_numeric()) }} as loyalty_points_balance,
        nullif(trim({{ dbt.safe_cast('acquisition_source', dbt.type_string()) }}), '') as acquisition_source
    from source_customers

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
    acquisition_source
from normalized_customers
