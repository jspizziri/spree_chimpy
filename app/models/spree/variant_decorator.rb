Spree::Variant.class_eval do

  after_commit :sync_with_mail_chimp

  def sync_with_mail_chimp
    Spree::Chimpy.enqueue(:product, self.product) if Spree::Chimpy.configured? && !self.product.nil?
  end
end
