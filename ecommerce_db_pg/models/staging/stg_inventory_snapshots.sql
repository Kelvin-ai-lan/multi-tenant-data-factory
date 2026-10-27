with source_inventory as (

    select
        product_id,
        snapshot_date,
        ending_inventory_units,
        units_sold_week,
        reorder_point,
        is_stockout,
        sell_through_rate
    from {{ source('raw_ecommerce', 'Inventory_History') }}

),

normalized_inventory as (

    select
        nullif(trim({{ dbt.safe_cast('product_id', dbt.type_string()) }}), '') as product_id,
        {{ dbt.safe_cast('snapshot_date', dbt.type_timestamp()) }} as snapshot_timestamp,
        {{ dbt.safe_cast('ending_inventory_units', dbt.type_int()) }} as ending_inventory_units,
        {{ dbt.safe_cast('units_sold_week', dbt.type_int()) }} as units_sold_week,
        {{ dbt.safe_cast('reorder_point', dbt.type_int()) }} as reorder_point_units,
        {{ dbt.safe_cast('is_stockout', dbt.type_boolean()) }} as is_stockout,
        {{ dbt.safe_cast('sell_through_rate', dbt.type_numeric()) }} as sell_through_rate
    from source_inventory

)

select *
from normalized_inventory
