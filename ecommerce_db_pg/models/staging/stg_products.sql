with source_products as (

    select
        product_id,
        product_name,
        category,
        brand,
        sku,
        base_price,
        cost_price,
        weight_kg,
        product_status,
        cost_price_num,
        base_price_num,
        cost_data_available,
        negative_margin_flag,
        duplicate_name_group,
        cleaning_negative_margin_review,
        cleaning_missing_brand,
        cleaning_missing_cost_price,
        cleaning_missing_weight,
        base_price_original,
        cost_price_status,
        brand_status,
        weight_status
    from {{ source('raw_ecommerce', 'Products_v2') }}

),

formatted_products as (

    select
        product_id,
        product_name,
        category,
        brand,
        sku,
        base_price,
        cost_price,
        weight_kg,
        product_status,
        cost_price_num,
        base_price_num,
        cost_data_available,
        negative_margin_flag,
        duplicate_name_group,
        cleaning_negative_margin_review,
        cleaning_missing_brand,
        cleaning_missing_cost_price,
        cleaning_missing_weight,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('base_price', dbt.type_string()) }}, ',', ''),
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
        ) as base_price_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('cost_price', dbt.type_string()) }}, ',', ''),
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
        ) as cost_price_clean,
        nullif(
            trim(
                replace(
                    replace(
                        replace(
                            replace({{ dbt.safe_cast('base_price_original', dbt.type_string()) }}, ',', ''),
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
        ) as base_price_original_clean,
        cost_price_status,
        brand_status,
        weight_status
    from source_products

),

normalized_products as (

    select
        nullif(trim({{ dbt.safe_cast('product_id', dbt.type_string()) }}), '') as product_id,
        nullif(trim({{ dbt.safe_cast('product_name', dbt.type_string()) }}), '') as product_name,
        nullif(trim({{ dbt.safe_cast('category', dbt.type_string()) }}), '') as product_category,
        nullif(trim({{ dbt.safe_cast('brand', dbt.type_string()) }}), '') as brand,
        nullif(trim({{ dbt.safe_cast('sku', dbt.type_string()) }}), '') as sku_code,
        coalesce(
            {{ dbt.safe_cast('base_price_num', dbt.type_numeric()) }},
            {{ dbt.safe_cast('base_price_clean', dbt.type_numeric()) }}
        ) as base_price_amount,
        coalesce(
            {{ dbt.safe_cast('cost_price_num', dbt.type_numeric()) }},
            {{ dbt.safe_cast('cost_price_clean', dbt.type_numeric()) }}
        ) as cost_price_amount,
        {{ dbt.safe_cast('weight_kg', dbt.type_numeric()) }} as weight_kg,
        nullif(trim({{ dbt.safe_cast('product_status', dbt.type_string()) }}), '') as product_status,
        {{ dbt.safe_cast('cost_data_available', dbt.type_boolean()) }} as cost_data_available,
        {{ dbt.safe_cast('negative_margin_flag', dbt.type_boolean()) }} as negative_margin_flag,
        {{ dbt.safe_cast('duplicate_name_group', dbt.type_boolean()) }} as duplicate_name_group,
        {{ dbt.safe_cast('cleaning_negative_margin_review', dbt.type_boolean()) }} as negative_margin_review_required,
        {{ dbt.safe_cast('cleaning_missing_brand', dbt.type_boolean()) }} as missing_brand_flag,
        {{ dbt.safe_cast('cleaning_missing_cost_price', dbt.type_boolean()) }} as missing_cost_price_flag,
        {{ dbt.safe_cast('cleaning_missing_weight', dbt.type_boolean()) }} as missing_weight_flag,
        {{ dbt.safe_cast('base_price_original_clean', dbt.type_numeric()) }} as original_base_price_amount,
        nullif(trim({{ dbt.safe_cast('cost_price_status', dbt.type_string()) }}), '') as cost_price_status,
        nullif(trim({{ dbt.safe_cast('brand_status', dbt.type_string()) }}), '') as brand_status,
        nullif(trim({{ dbt.safe_cast('weight_status', dbt.type_string()) }}), '') as weight_status
    from formatted_products

)

select *
from normalized_products
