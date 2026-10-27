with source_marketing_touchpoints as (

    select
        touchpoint_id,
        campaign_id,
        campaign_name,
        click_id,
        customer_pseudo_key,
        event_timestamp,
        channel,
        device,
        customer_id
    from {{ source('raw_ecommerce', 'Marketing_Touchpoints') }}

),

normalized_marketing_touchpoints as (

    select
        nullif(trim({{ dbt.safe_cast('touchpoint_id', dbt.type_string()) }}), '') as touchpoint_id,
        nullif(trim({{ dbt.safe_cast('campaign_id', dbt.type_string()) }}), '') as campaign_id,
        nullif(trim({{ dbt.safe_cast('campaign_name', dbt.type_string()) }}), '') as campaign_name,
        nullif(trim({{ dbt.safe_cast('click_id', dbt.type_string()) }}), '') as click_id,
        nullif(trim({{ dbt.safe_cast('customer_pseudo_key', dbt.type_string()) }}), '') as customer_pseudo_key,
        {{ dbt.safe_cast('event_timestamp', dbt.type_timestamp()) }} as event_timestamp,
        nullif(trim({{ dbt.safe_cast('channel', dbt.type_string()) }}), '') as channel,
        nullif(trim({{ dbt.safe_cast('device', dbt.type_string()) }}), '') as device_type,
        nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), '') as customer_id
    from source_marketing_touchpoints

)

select *
from normalized_marketing_touchpoints
