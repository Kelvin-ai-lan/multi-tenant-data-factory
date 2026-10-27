with source_returns as (

    select
        return_id,
        order_id,
        customer_id,
        return_date,
        return_reason,
        returned_quantity,
        refund_amount,
        refund_status,
        currency
    from {{ source('raw_ecommerce', 'Returns_Refunds') }}

),

formatted_returns as (

    select
        return_id,
        order_id,
        customer_id,
        return_date,
        return_reason,
        returned_quantity,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('refund_amount', dbt.type_string()) }}, ',', ''),
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
        ) as refund_amount_clean,
        refund_status,
        currency
    from source_returns

),

normalized_returns as (

    select
        nullif(trim({{ dbt.safe_cast('return_id', dbt.type_string()) }}), '') as return_id,
        nullif(trim({{ dbt.safe_cast('order_id', dbt.type_string()) }}), '') as order_id,
        nullif(trim({{ dbt.safe_cast('customer_id', dbt.type_string()) }}), '') as customer_id,
        {{ dbt.safe_cast('return_date', dbt.type_timestamp()) }} as return_timestamp,
        nullif(trim({{ dbt.safe_cast('return_reason', dbt.type_string()) }}), '') as return_reason,
        {{ dbt.safe_cast('returned_quantity', dbt.type_int()) }} as returned_quantity,
        {{ dbt.safe_cast('refund_amount_clean', dbt.type_numeric()) }} as refund_amount,
        nullif(trim({{ dbt.safe_cast('refund_status', dbt.type_string()) }}), '') as refund_status,
        upper(trim({{ dbt.safe_cast('currency', dbt.type_string()) }})) as currency_code
    from formatted_returns

)

select *
from normalized_returns
