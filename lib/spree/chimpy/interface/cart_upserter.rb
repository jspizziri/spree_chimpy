require_relative 'customer_upserter'
require_relative 'products'
require_relative 'spree_order_upserter'

module Spree::Chimpy
  module Interface
    class CartUpserter < SpreeOrderUpserter

      def cart_hash
        data = common_hash
        data[:checkout_url] = "#{Spree::Store.current.url}/orders/#{@order.number}/edit"

        data
      end

      def perform_upsert
        if (@order.completed?)
          # Abandoned Cart automations will continue to send emails for any Cart in
          # the system, so we need to remove Carts as soon as an order is completed
          remove_cart if mail_chimp_cart_exists?
        else
          # If the order is not complete, update the cart unless an Order record
          # already exists in MailChimp)
          add_or_update_cart unless mail_chimp_order_exists?
        end
      end

      def add_or_update_cart
        data = cart_hash

        if (data[:campaign_id])
          log "Cart #{@order.number} is linked to campaign #{data[:campaign_id]}"
        end

        if mail_chimp_cart_exists?
          log "Updating cart #{@order.number} for #{data[:customer][:id]}"
          update_cart(data)
        else
          log "Cart #{@order.number} Not Found, creating cart"
          create_cart(data)
        end
      end

      def update_cart(data)
        # NOTE: Due to a shortfall of the API's design, it is currently impossible to delete
        # individual line items. If users remove an item from their cart, the only way to sync
        # that change with MailChimp is to remove the Cart record entirely and recreate it.
        #
        # As a result, this method is a shorthand that will delete any previously synced versions
        # of the cart and then push a new copy into MailChimp

        log "Cart #{@order.number} has been modified. Deleting previous version of Cart record in MailChimp"
        remove_cart

        log "Pushing updated cart data for #{@order.number}."
        create_cart(data) unless @order.line_items.empty?
      end

      def remove_cart
        begin
          store_api_call.carts(@order.number).delete
          # NOTE: Once an Order is complete, we want to remove the Cart record
          # from MailChimp because it is no longer relevant.
          #
          #     NOTE: If the cart is not removed, then it would be included in
          #     automated Abandoned Cart campaigns, which should not happen if
          #     the customer has completed their order.
        rescue Gibbon::MailChimpError => e
          log "Unable to remove cart #{@order.number}. [#{e.raw_body}]"
        end
      end

      def create_cart(data)
        begin
          store_api_call.carts.create(body: data) unless(mail_chimp_order_exists?)

        rescue Gibbon::MailChimpError => e
          log "Unable to create cart #{@order.number}. [#{e.raw_body}]"
        end
      end

    end
  end
end
