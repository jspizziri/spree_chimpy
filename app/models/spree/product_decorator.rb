Spree::Product.class_eval do

  after_commit on: [:update, :create] do
    sync_with_mail_chimp(self)
  end

  before_commit on: [:destroy] do
    delete_product_in_mail_chimp(self)
  end

  def sync_with_mail_chimp(product)
    Spree::Chimpy::Interface::Products.sync_product(product)
  end

  def delete_product_in_mail_chimp(product)
    Spree::Chimpy::Interface::Products.delete_product(product)
  end
end
