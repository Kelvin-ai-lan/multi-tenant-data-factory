with source_campaign_performance as (

    select
        campaign_id,
        campaign_name,
        date,
        channel,
        impressions,
        clicks,
        spend,
        attributed_orders,
        attributed_revenue,
        currency
    from {{ source('raw_ecommerce', 'Campaign_Performance_Daily_v2') }}

),

formatted_campaign_performance as (

    select
        campaign_id,
        campaign_name,
        date,
        channel,
        impressions,
        clicks,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('spend', dbt.type_string()) }}, ',', ''),
                            '$',
                            ''
                        ),
                        '€',
                        ''
                    ),
                    '£',
                    ''
                )
            ),
            ''
        ) as spend_clean,
        attributed_orders,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('attributed_revenue', dbt.type_string()) }}, ',', ''),
                            '$',
                            ''
                        ),
                        '€',
                        ''
                    ),
                    '£',
                    ''
                )
            ),
            ''
        ) as attributed_revenue_clean,
        currency
    from source_campaign_performance

),

normalized_campaign_performance as (

    select
        nullif(trim({{ dbt.safe_cast('campaign_id', dbt.type_string()) }}), '') as campaign_id,
        nullif(trim({{ dbt.safe_cast('campaign_name', dbt.type_string()) }}), '') as campaign_name,
        {{ dbt.safe_cast('date', dbt.type_timestamp()) }} as performance_timestamp,
        nullif(trim({{ dbt.safe_cast('channel', dbt.type_string()) }}), '') as channel,
        {{ dbt.safe_cast('impressions', dbt.type_int()) }} as impression_count,
        {{ dbt.safe_cast('clicks', dbt.type_int()) }} as click_count,
        {{ dbt.safe_cast('spend_clean', dbt.type_numeric()) }} as spend_amount,
        {{ dbt.safe_cast('attributed_orders', dbt.type_int()) }} as attributed_order_count,
        {{ dbt.safe_cast('attributed_revenue_clean', dbt.type_numeric()) }} as attributed_revenue_amount,
        upper(trim({{ dbt.safe_cast('currency', dbt.type_string()) }})) as currency_code
    from formatted_campaign_performance

)

select *
from normalized_campaign_performance
