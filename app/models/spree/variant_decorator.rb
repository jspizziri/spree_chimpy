Spree::Variant.class_eval do

  after_commit on: [:update, :create] do
    sync_with_mail_chimp(self)
  end

  before_commit on: [:destroy] do
    delete_variant_in_mail_chimp(self)
  end

  def sync_with_mail_chimp(variant)
    Spree::Chimpy::Interface::Products.sync_variant(variant)
  end

  def delete_variant_in_mail_chimp(variant)
    Spree::Chimpy::Interface::Products.delete_variant(variant)
  end
end
