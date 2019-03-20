require 'spec_helper'

describe Spree::Chimpy::Interface::Products do
  let(:store_api) { double(:store_api) }

  let(:product_api) { double(:product_api) }
  let(:products_api) { double(:products_api) }

  let(:product) { create(:product) }

  before(:each) do
    allow(Spree::Chimpy).to receive(:store_api_call) { store_api }
    allow(store_api).to receive(:products) { products_api }
  end

  context "adding a product" do
    it "calls the product upserter" do

      expect_any_instance_of(Spree::Chimpy::Interface::ProductUpserter).to receive(:upsert)
      interface.add(product)
    end
  end
end
