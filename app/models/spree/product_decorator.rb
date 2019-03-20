Spree::Product.class_eval do

  after_commit :sync_with_mail_chimp

  def sync_with_mail_chimp
    Spree::Chimpy.enqueue(:product, self) if Spree::Chimpy.configured?
  end
end
