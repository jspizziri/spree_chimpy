module Spree::Chimpy
  module Interface
    class ProductUpserter
      delegate :log, :store_api_call, to: Spree::Chimpy

      def initialize(product)
        @product = product
      end

      def upsert
        return unless @product.id

        data = product_hash

        begin
          if mail_chimp_product_exists?
            log "Updating #{@product.name} record in MailChimp"
            store_api_call.products(@product.id.to_s).update(body: data)
          else
            log "#{@product.name} record does not exist in MailChimp. Create it."
            store_api_call.products.create(body: data)
          end

        rescue Gibbon::MailChimpError => e
          log "Unable to sync #{@product.name}. [#{e.raw_body}]"
        end
      end

      def mail_chimp_product_exists?
        response = store_api_call
          .products(@product.id)
          .retrieve(params: { "fields" => "id" })
          .body
        !response["id"].nil?
      rescue Gibbon::MailChimpError => e
        false
      end

      def product_hash
        root_taxon = Spree::Taxon.where(parent_id: nil).take
        taxon = @product.taxons.map(&:self_and_ancestors).flatten.uniq.detect { |t| t.parent == root_taxon }

        # assign a default taxon if the product is not associated with a category
        taxon = root_taxon if taxon.blank?

        all_variants = @product.variants.any? ? @product.variants : [@product.master]
        data = {
          id: @product.id.to_s,
          title: @product.name,
          handle: @product.slug,
          url: self.class.product_url_or_default(@product),
          variants: all_variants.map { |v| self.class.variant_hash(v) },
          type: taxon.name
        }

        if @product.images.any?
          data[:image_url] = @product.images.first.attachment.url(:product)
        end

        if @product.respond_to?(:available_on) && @product.available_on
          data[:published_at_foreign] = @product.available_on.to_formatted_s(:db)
        end

        data
      end

      def self.variant_hash(variant)
        data = {
          id: variant.id.to_s,
          title: variant.name,
          sku: variant.sku,
          url: product_url_or_default(variant.product),
          price: variant.price.to_f,

          inventory_quantity: variant.total_on_hand == Float::INFINITY ? 999 : variant.total_on_hand
        }

        if variant.images.any?
          data[:image_url] = variant_image_url variant
        end

        data
      end

      def self.variant_image_url(variant)
        if variant.images.any?
          variant.images.first.attachment.url(:product)
        elsif variant.product.images.any?
          variant.product.images.first.attachment.url(:product)
        end
      end

      def self.product_url_or_default(product)
          if self.respond_to?(:product_url)
              product_url(product)
          else
              URI::HTTP.build({
                host: Spree::Store.current.url.gsub(/(^\w+:|^)\/\//,''),
                :path => "/products/#{product.slug}"}
              ).to_s
          end
      end

    end
  end
end
