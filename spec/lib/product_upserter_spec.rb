require 'spec_helper'

describe Spree::Chimpy::Interface::ProductUpserter do
  let(:store_api) { double(:store_api) }
  let(:customer_id) { "customer_123" }

  let(:product_api) { double(:product_api) }
  let(:products_api) { double(:products_api) }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
    allow(store_api).to receive(:products) { products_api }
  end

  describe "#upsert" do
    let(:product) { create(:product) }
    let(:interface) { described_class.new(product) }

    def check_hash(h)
      body = h[:body]
      expect(body[:id]).to eq product.id
      expect(body[:title]).to eq product.name
      expect(body[:handle]).to eq product.slug
      expect(body[:url]).to eq product.url
      expect(body[:description]).to eq product.description
    end

    before(:each) do
      allow(store_api).to receive(:products)
        .and_return(products_api)
      allow(store_api).to receive(:orders)
        .with(anything)
        .and_return(order_api))
    end

    context "when product already exists" do
      before(:each) do
        allow(product_api).to receive(:retrieve)
          .and_return({ "id" => product.id })
      end

      it "updates a found order" do
        expect(product_api).to receive(:update) do |h|
          check_hash(h)
        end
        interface.upsert
      end
    end

    context "When a product is not found" do
      before(:each) do
        allow(product_api).to receive(:retrieve)
          .and_raise(Gibbon::MailCHimpError)
      end

      it "creates product" do
        expect(products_api).to receive(:create) do |h|
          check_hash(h)
        end
        interface.upsert
      end
    end

  end
end
