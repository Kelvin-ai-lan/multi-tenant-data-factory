with source_orders as (
    select order_id,
        order_line_id,
        transaction_id,
        order_date_raw,
        order_date_parsed,
        customer_id,
        customer_id_normalized,
        product_id,
        product_category,
        product_name,
        quantity_raw,
        quantity_num,
        unit_price_raw,
        unit_price_num,
        total_amount_raw,
        total_amount_num,
        customer_location,
        payment_method,
        order_status,
        campaign_name,
        channel,
        utm_source,
        is_exact_duplicate_row,
        is_quarantined,
        resolution_status,
        resolution_rule,
        currency,
        order_country,
        tax_rate_applied,
        subtotal,
        discount_amount,
        tax_amount,
        shipping_fee,
        total_amount_recognized,
        net_revenue,
        gross_revenue,
        cancellation_reason,
        payment_fee,
        fulfillment_cost,
        shipping_cost,
        authorization_status,
        settlement_date,
        fraud_flag,
        promo_code,
        discount_type
    from {{ source('raw_ecommerce', 'Orders_v2') }}
),
base_orders as (
    select *
    from source_orders
    where coalesce(
            {{ dbt.safe_cast('is_quarantined', dbt.type_boolean()) }},
            false
        ) = false
        and coalesce(
            {{ dbt.safe_cast('is_exact_duplicate_row', dbt.type_boolean()) }},
            false
        ) = false
),
cleaned_orders as (
    select nullif(
            trim(
                {{ dbt.safe_cast('transaction_id', dbt.type_string()) }}
            ),
            ''
        ) as transaction_id_clean,
        nullif(
            trim(
                {{ dbt.safe_cast('order_id', dbt.type_string()) }}
            ),
            ''
        ) as order_id_clean,
        nullif(
            trim(
                {{ dbt.safe_cast('customer_id_normalized', dbt.type_string()) }}
            ),
            ''
        ) as customer_id_normalized_clean,
        nullif(
            trim(
                {{ dbt.safe_cast('customer_id', dbt.type_string()) }}
            ),
            ''
        ) as customer_id_clean,
        order_line_id,
        order_date_raw,
        order_date_parsed,
        product_id,
        product_category,
        product_name,
        quantity_raw,
        quantity_num,
        unit_price_raw,
        unit_price_num,
        total_amount_raw,
        total_amount_num,
        customer_location,
        payment_method,
        order_status,
        campaign_name,
        channel,
        utm_source,
        is_exact_duplicate_row,
        is_quarantined,
        resolution_status,
        resolution_rule,
        currency,
        order_country,
        tax_rate_applied,
        subtotal,
        discount_amount,
        tax_amount,
        shipping_fee,
        total_amount_recognized,
        net_revenue,
        gross_revenue,
        cancellation_reason,
        payment_fee,
        fulfillment_cost,
        shipping_cost,
        authorization_status,
        settlement_date,
        fraud_flag,
        promo_code,
        discount_type,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('unit_price_raw', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as unit_price_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('total_amount_raw', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as total_amount_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('subtotal', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as subtotal_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('discount_amount', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as discount_amount_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('tax_amount', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as tax_amount_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('shipping_fee', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as shipping_fee_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('total_amount_recognized', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as total_amount_recognized_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('net_revenue', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as net_revenue_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('gross_revenue', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as gross_revenue_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('payment_fee', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as payment_fee_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('fulfillment_cost', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as fulfillment_cost_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace(
                                {{ dbt.safe_cast('shipping_cost', dbt.type_string()) }},
                                ',',
                                ''
                            ),
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
        ) as shipping_cost_clean
    from base_orders
),
typed_orders as (
    select coalesce(transaction_id_clean, order_id_clean) as order_id,
        {{ dbt.safe_cast('order_line_id', dbt.type_string()) }} as order_line_id,
        coalesce(customer_id_normalized_clean, customer_id_clean) as customer_id,
        coalesce(
            {{ dbt.safe_cast('order_date_parsed', dbt.type_timestamp()) }},
            {{ dbt.safe_cast('order_date_raw', dbt.type_timestamp()) }}
        ) as order_timestamp,
        {{ dbt.safe_cast('product_id', dbt.type_string()) }} as product_id,
        {{ dbt.safe_cast('product_category', dbt.type_string()) }} as product_category,
        {{ dbt.safe_cast('product_name', dbt.type_string()) }} as product_name,
        coalesce(
            {{ dbt.safe_cast('quantity_num', dbt.type_numeric()) }},
            {{ dbt.safe_cast('quantity_raw', dbt.type_numeric()) }}
        ) as quantity,
        coalesce(
            {{ dbt.safe_cast('unit_price_clean', dbt.type_numeric()) }},
            {{ dbt.safe_cast('unit_price_num', dbt.type_numeric()) }}
        ) as unit_price,
        coalesce(
            {{ dbt.safe_cast('total_amount_clean', dbt.type_numeric()) }},
            {{ dbt.safe_cast('total_amount_num', dbt.type_numeric()) }}
        ) as line_total_amount,
        {{ dbt.safe_cast('customer_location', dbt.type_string()) }} as customer_location,
        {{ dbt.safe_cast('payment_method', dbt.type_string()) }} as payment_method,
        {{ dbt.safe_cast('order_status', dbt.type_string()) }} as order_status,
        {{ dbt.safe_cast('campaign_name', dbt.type_string()) }} as campaign_name,
        {{ dbt.safe_cast('channel', dbt.type_string()) }} as channel,
        {{ dbt.safe_cast('utm_source', dbt.type_string()) }} as utm_source,
        {{ dbt.safe_cast('resolution_status', dbt.type_string()) }} as resolution_status,
        {{ dbt.safe_cast('resolution_rule', dbt.type_string()) }} as resolution_rule,
        upper(
            trim(
                {{ dbt.safe_cast('currency', dbt.type_string()) }}
            )
        ) as currency_code,
        upper(
            trim(
                {{ dbt.safe_cast('order_country', dbt.type_string()) }}
            )
        ) as order_country_code,
        {{ dbt.safe_cast('tax_rate_applied', dbt.type_numeric()) }} as tax_rate,
        {{ dbt.safe_cast('subtotal_clean', dbt.type_numeric()) }} as subtotal_amount,
        {{ dbt.safe_cast('discount_amount_clean', dbt.type_numeric()) }} as discount_amount,
        {{ dbt.safe_cast('tax_amount_clean', dbt.type_numeric()) }} as tax_amount,
        {{ dbt.safe_cast('shipping_fee_clean', dbt.type_numeric()) }} as shipping_amount,
        {{ dbt.safe_cast(
            'total_amount_recognized_clean',
            dbt.type_numeric()
        ) }} as recognized_total_amount,
        {{ dbt.safe_cast('net_revenue_clean', dbt.type_numeric()) }} as net_revenue_amount,
        {{ dbt.safe_cast('gross_revenue_clean', dbt.type_numeric()) }} as gross_revenue_amount,
        {{ dbt.safe_cast('cancellation_reason', dbt.type_string()) }} as cancellation_reason,
        {{ dbt.safe_cast('payment_fee_clean', dbt.type_numeric()) }} as payment_fee_amount,
        {{ dbt.safe_cast('fulfillment_cost_clean', dbt.type_numeric()) }} as fulfillment_cost_amount,
        {{ dbt.safe_cast('shipping_cost_clean', dbt.type_numeric()) }} as shipping_cost_amount,
        {{ dbt.safe_cast('authorization_status', dbt.type_string()) }} as authorization_status,
        {{ dbt.safe_cast('settlement_date', dbt.type_timestamp()) }} as settlement_timestamp,
        {{ dbt.safe_cast('fraud_flag', dbt.type_boolean()) }} as fraud_flag,
        {{ dbt.safe_cast('promo_code', dbt.type_string()) }} as promo_code,
        {{ dbt.safe_cast('discount_type', dbt.type_string()) }} as discount_type,
        {{ dbt.safe_cast('is_exact_duplicate_row', dbt.type_boolean()) }} as is_exact_duplicate_row,
        {{ dbt.safe_cast('is_quarantined', dbt.type_boolean()) }} as is_quarantined
    from cleaned_orders
)
select *
from typed_orders