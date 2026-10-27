with source_subscriptions as (

    select
        subscription_id,
        customer_id,
        plan_name,
        mrr_amount,
        currency,
        billing_start_date,
        billing_status,
        billing_end_date,
        cancel_reason
    from {{ source('raw_ecommerce', 'Subscription_Billing') }}

),

formatted_subscriptions as (

    select
        subscription_id,
        customer_id,
        plan_name,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('mrr_amount', dbt.type_string()) }}, ',', ''),
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
        ) as mrr_amount_clean,
        currency,
        billing_start_date,
        billing_status,
        billing_end_date,
        cancel_reason
    from source_subscriptions

),

normalized_subscriptions as (

    select
        nullif(trim({{ dbt.safe_cast('subscription_id', dbt.type_string()) }}), '') as subscription_id,
        nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), '') as customer_id,
        nullif(trim({{ dbt.safe_cast('plan_name', dbt.type_string()) }}), '') as plan_name,
        {{ dbt.safe_cast('mrr_amount_clean', dbt.type_numeric()) }} as monthly_recurring_revenue_amount,
        upper(trim({{ dbt.safe_cast('currency', dbt.type_string()) }})) as currency_code,
        {{ dbt.safe_cast('billing_start_date', dbt.type_timestamp()) }} as billing_start_timestamp,
        nullif(trim({{ dbt.safe_cast('billing_status', dbt.type_string()) }}), '') as billing_status,
        {{ dbt.safe_cast('billing_end_date', dbt.type_timestamp()) }} as billing_end_timestamp,
        nullif(trim({{ dbt.safe_cast('cancel_reason', dbt.type_string()) }}), '') as cancellation_reason
    from formatted_subscriptions

)

select *
from normalized_subscriptions
