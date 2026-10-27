with campaign_performance as (

    select
        campaign_id,
        campaign_name,
        currency_code,
        min(performance_timestamp) as first_performance_timestamp,
        max(performance_timestamp) as last_performance_timestamp,
        sum(coalesce(spend_amount, 0)) as total_spend_amount,
        sum(coalesce(impression_count, 0)) as total_impression_count,
        sum(coalesce(click_count, 0)) as total_click_count,
        sum(coalesce(attributed_order_count, 0)) as reported_conversion_count,
        sum(coalesce(attributed_revenue_amount, 0)) as reported_attributed_revenue_amount
    from {{ ref('stg_campaign_spend') }}
    group by
        campaign_id,
        campaign_name,
        currency_code

),

campaign_attribution as (

    select
        campaign_id,
        currency_code,
        count(distinct order_id) as linked_order_count,
        sum(coalesce(credit_share, 0)) as total_conversions_linked
    from {{ ref('stg_attribution') }}
    where campaign_id is not null
    group by
        campaign_id,
        currency_code

),

campaign_metrics as (

    select
        campaign_performance.campaign_id,
        campaign_performance.campaign_name,
        campaign_performance.currency_code,
        campaign_performance.first_performance_timestamp,
        campaign_performance.last_performance_timestamp,
        campaign_performance.total_spend_amount,
        campaign_performance.total_impression_count,
        campaign_performance.total_click_count,
        campaign_performance.reported_conversion_count,
        campaign_performance.reported_attributed_revenue_amount,
        coalesce(campaign_attribution.linked_order_count, 0) as linked_order_count,
        coalesce(campaign_attribution.total_conversions_linked, 0) as total_conversions_linked
    from campaign_performance
    left join campaign_attribution
        on campaign_performance.campaign_id = campaign_attribution.campaign_id
        and (
            campaign_performance.currency_code = campaign_attribution.currency_code
            or (
                campaign_performance.currency_code is null
                and campaign_attribution.currency_code is null
            )
        )

)

select
    campaign_id,
    campaign_name,
    currency_code,
    first_performance_timestamp,
    last_performance_timestamp,
    total_spend_amount,
    total_impression_count,
    total_click_count,
    reported_conversion_count,
    reported_attributed_revenue_amount,
    linked_order_count,
    total_conversions_linked,
    case
        when total_impression_count = 0 then null
        else total_click_count * 1.0 / total_impression_count
    end as click_through_rate,
    case
        when total_conversions_linked = 0 then null
        else total_spend_amount / total_conversions_linked
    end as cost_per_acquisition
from campaign_metrics
