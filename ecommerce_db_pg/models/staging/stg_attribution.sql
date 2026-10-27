with source_attribution as (

    select
        order_id,
        touchpoint_id,
        campaign_id,
        campaign_name,
        attribution_model,
        credit_share,
        currency
    from {{ source('raw_ecommerce', 'Attribution_Bridge_v2') }}

),

normalized_attribution as (

    select
        nullif(trim({{ dbt.safe_cast('order_id', dbt.type_string()) }}), '') as order_id,
        nullif(trim({{ dbt.safe_cast('touchpoint_id', dbt.type_string()) }}), '') as touchpoint_id,
        nullif(trim({{ dbt.safe_cast('campaign_id', dbt.type_string()) }}), '') as campaign_id,
        nullif(trim({{ dbt.safe_cast('campaign_name', dbt.type_string()) }}), '') as campaign_name,
        nullif(trim({{ dbt.safe_cast('attribution_model', dbt.type_string()) }}), '') as attribution_model,
        {{ dbt.safe_cast('credit_share', dbt.type_numeric()) }} as credit_share,
        upper(trim({{ dbt.safe_cast('currency', dbt.type_string()) }})) as currency_code
    from source_attribution

)

select *
from normalized_attribution
