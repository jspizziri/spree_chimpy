module Spree::Chimpy
  module Interface
    class Products
      delegate :log, :store_api_call, to: Spree::Chimpy
      include Spree.railtie_routes_url_helpers

      def initialize()
      end

      def add(product)
        ProductUpserter.new(product).upsert
      end

      def sync(product)
        add(product)
      rescue Gibbon::MailChimpError => e
        log "failed syncing #{product.name} [#{e.raw_body}]"
      end
    end
  end
end
