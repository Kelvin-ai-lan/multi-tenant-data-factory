with subscription_contracts as (

    select
        subscription_id,
        customer_id,
        plan_name,
        monthly_recurring_revenue_amount,
        currency_code,
        billing_start_timestamp,
        billing_status,
        billing_end_timestamp,
        cancellation_reason
    from {{ ref('stg_subscriptions') }}

),

classified_subscription_contracts as (

    select
        subscription_id,
        customer_id,
        plan_name,
        monthly_recurring_revenue_amount,
        currency_code,
        {{ dbt.date_trunc('month', 'billing_start_timestamp') }} as billing_cycle_month,
        billing_end_timestamp,
        cancellation_reason,
        case
            when upper(trim(billing_status)) in ('CANCELLED', 'CANCELED', 'CHURNED', 'TERMINATED', 'ENDED')
                or billing_end_timestamp is not null
                then 'cancelled'
            when upper(trim(billing_status)) = 'ACTIVE'
                then 'active'
            else 'unknown'
        end as subscription_state
    from subscription_contracts

),

subscription_revenue_by_cycle as (

    select
        billing_cycle_month,
        plan_name,
        currency_code,
        count(distinct subscription_id) as subscription_count,
        count(distinct customer_id) as customer_count,
        sum(
            case
                when subscription_state = 'active'
                    then coalesce(monthly_recurring_revenue_amount, 0)
                else 0
            end
        ) as active_mrr_amount,
        sum(
            case
                when subscription_state = 'cancelled'
                    then coalesce(monthly_recurring_revenue_amount, 0)
                else 0
            end
        ) as cancelled_mrr_amount,
        sum(
            case
                when subscription_state = 'active' then 1
                else 0
            end
        ) as active_subscription_count,
        sum(
            case
                when subscription_state = 'cancelled' then 1
                else 0
            end
        ) as cancelled_subscription_count,
        sum(
            case
                when subscription_state = 'unknown' then 1
                else 0
            end
        ) as unknown_state_subscription_count
    from classified_subscription_contracts
    group by
        billing_cycle_month,
        plan_name,
        currency_code

)

select
    billing_cycle_month,
    plan_name,
    currency_code,
    subscription_count,
    customer_count,
    active_mrr_amount,
    cancelled_mrr_amount,
    active_subscription_count,
    cancelled_subscription_count,
    unknown_state_subscription_count,
    case
        when subscription_count = 0 then null
        else cancelled_subscription_count * 1.0 / subscription_count
    end as churned_subscription_share,
    case
        when cancelled_subscription_count > 0 then true
        else false
    end as has_churned_subscriptions
from subscription_revenue_by_cycle
