with source_fulfillment as (

    select
        order_id,
        carrier,
        ship_date,
        promised_delivery_date,
        actual_delivery_date,
        delivery_status,
        shipping_cost_actual,
        currency,
        destination_country
    from {{ source('raw_ecommerce', 'Delivery_Fulfillment') }}

),

formatted_fulfillment as (

    select
        order_id,
        carrier,
        ship_date,
        promised_delivery_date,
        actual_delivery_date,
        delivery_status,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('shipping_cost_actual', dbt.type_string()) }}, ',', ''),
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
        ) as shipping_cost_actual_clean,
        currency,
        destination_country
    from source_fulfillment

),

normalized_fulfillment as (

    select
        nullif(trim({{ dbt.safe_cast('order_id', dbt.type_string()) }}), '') as order_id,
        nullif(trim({{ dbt.safe_cast('carrier', dbt.type_string()) }}), '') as carrier,
        {{ dbt.safe_cast('ship_date', dbt.type_timestamp()) }} as shipped_timestamp,
        {{ dbt.safe_cast('promised_delivery_date', dbt.type_timestamp()) }} as promised_delivery_timestamp,
        {{ dbt.safe_cast('actual_delivery_date', dbt.type_timestamp()) }} as actual_delivery_timestamp,
        nullif(trim({{ dbt.safe_cast('delivery_status', dbt.type_string()) }}), '') as delivery_status,
        {{ dbt.safe_cast('shipping_cost_actual_clean', dbt.type_numeric()) }} as actual_shipping_cost,
        upper(trim({{ dbt.safe_cast('currency', dbt.type_string()) }})) as currency_code,
        upper(trim({{ dbt.safe_cast('destination_country', dbt.type_string()) }})) as destination_country_code
    from formatted_fulfillment

)

select *
from normalized_fulfillment
