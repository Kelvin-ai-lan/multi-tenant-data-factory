with order_metrics as (

    select
        order_id,
        customer_id,
        currency_code,
        min(order_timestamp) as order_timestamp,
        sum(coalesce(gross_revenue_amount, 0)) as gross_order_revenue_amount
    from {{ ref('stg_orders') }}
    where order_id is not null
    group by
        order_id,
        customer_id,
        currency_code

),

shipment_metrics as (

    select
        order_id,
        currency_code,
        min(shipped_timestamp) as first_shipped_timestamp,
        min(promised_delivery_timestamp) as promised_delivery_timestamp,
        max(actual_delivery_timestamp) as actual_delivery_timestamp,
        count(*) as shipment_record_count,
        sum(coalesce(actual_shipping_cost, 0)) as actual_shipping_cost_amount
    from {{ ref('stg_shipments') }}
    where order_id is not null
    group by
        order_id,
        currency_code

),

return_metrics as (

    select
        order_id,
        currency_code,
        count(*) as return_record_count,
        sum(coalesce(returned_quantity, 0)) as returned_unit_count,
        sum(coalesce(refund_amount, 0)) as total_refund_amount
    from {{ ref('stg_returns') }}
    where order_id is not null
    group by
        order_id,
        currency_code

),

order_fulfillment_metrics as (

    select
        order_metrics.order_id,
        order_metrics.customer_id,
        order_metrics.currency_code,
        order_metrics.order_timestamp,
        order_metrics.gross_order_revenue_amount,
        shipment_metrics.first_shipped_timestamp,
        shipment_metrics.promised_delivery_timestamp,
        shipment_metrics.actual_delivery_timestamp,
        coalesce(shipment_metrics.shipment_record_count, 0) as shipment_record_count,
        coalesce(shipment_metrics.actual_shipping_cost_amount, 0) as actual_shipping_cost_amount,
        coalesce(return_metrics.return_record_count, 0) as return_record_count,
        coalesce(return_metrics.returned_unit_count, 0) as returned_unit_count,
        coalesce(return_metrics.total_refund_amount, 0) as total_refund_amount
    from order_metrics
    left join shipment_metrics
        on order_metrics.order_id = shipment_metrics.order_id
        and (
            order_metrics.currency_code = shipment_metrics.currency_code
            or (
                order_metrics.currency_code is null
                and shipment_metrics.currency_code is null
            )
        )
    left join return_metrics
        on order_metrics.order_id = return_metrics.order_id
        and (
            order_metrics.currency_code = return_metrics.currency_code
            or (
                order_metrics.currency_code is null
                and return_metrics.currency_code is null
            )
        )

)

select
    order_id,
    customer_id,
    currency_code,
    order_timestamp,
    gross_order_revenue_amount,
    first_shipped_timestamp,
    promised_delivery_timestamp,
    actual_delivery_timestamp,
    shipment_record_count,
    actual_shipping_cost_amount,
    return_record_count,
    returned_unit_count,
    total_refund_amount,
    case
        when order_timestamp is null or actual_delivery_timestamp is null then null
        else {{ dbt.datediff('order_timestamp', 'actual_delivery_timestamp', 'hour') }}
    end as fulfillment_velocity_hours,
    case
        when promised_delivery_timestamp is null or actual_delivery_timestamp is null then null
        else {{ dbt.datediff('promised_delivery_timestamp', 'actual_delivery_timestamp', 'hour') }}
    end as delivery_promise_delta_hours,
    case
        when gross_order_revenue_amount = 0 then null
        else total_refund_amount / gross_order_revenue_amount
    end as refund_leakage_rate
from order_fulfillment_metrics
