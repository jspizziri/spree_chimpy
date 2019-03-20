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
        # NOTE:     In MailChimp, carts and orders are mutually exclusive. If
        # we are pushing an order, there should be no cart (and vice vesa). This
        # is built on the convention that this method only fires for INCOMPLETE
        # orders, and that the OrderUpserter (which fires only on COMPLETED orders)
        # will make the call to delete the cart
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

      def create_cart(data)
        begin
          store_api_call.carts.create(body: data)

        rescue Gibbon::MailChimpError => e
          log "Unable to create cart #{@order.number}. [#{e.raw_body}]"
        end
      end

    end
  end
end
