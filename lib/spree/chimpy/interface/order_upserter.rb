require_relative 'customer_upserter'
require_relative 'products'
require_relative 'spree_order_upserter'

module Spree::Chimpy
  module Interface
    class OrderUpserter < SpreeOrderUpserter

      def order_hash
        data = common_hash
          data[:financial_status] = @order.payment_state || ""
          data[:fulfillment_status] = @order.shipment_state || ""
          data[:shipping_total] = @order.ship_total.to_f

        data
      end

      def perform_upsert
        data = order_hash
        log "Adding order #{@order.number} for #{data[:customer][:id]}"
        if (data[:campaign_id])
          log "Order #{@order.number} is linked to campaign #{data[:campaign_id]}"
        end

        if mail_chimp_order_exists?
          log "Updating order #{@order.number} for #{data[:customer][:id]}"
          update_order(data)
        else
          log "Order #{@order.number} Not Found, creating order"
          create_order(data)
        end
      end

      def update_order(data)
        # NOTE: To reduce API calls, this assumes defunct cart records were removed
        # when the Order record was originally created
        store_api_call.orders(@order.number).update(body: data)
      end

      def create_order(data)
        # NOTE: In MailChimp, carts and orders are mutually exclusive. If we are
        # pushing an order, there should be no cart (and vice vesa). This  is
        # built on the convention that this method only fires for COMPLETED orders,
        # and handles deletion of the defunct Cart record
        begin
          log "Removing Cart #{@order.number} if it exists."
          remove_cart()

          store_api_call.orders.create(body: data)

        rescue Gibbon::MailChimpError => e
          log "Unable to create order #{@order.number}. [#{e.raw_body}]"
        end
      end

    end
  end
end
