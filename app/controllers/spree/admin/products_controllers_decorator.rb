Spree::Admin::ProductsController.class_eval do

  # Adds the ability to manually queue all products to sync with MailChimp.
  def push_all_to_mail_chimp
    Spree::Product.all.find_in_batches do |batch|
      batch.each do |product|
        product.sync_with_mail_chimp
      end
    end

    flash[:success] = 'MailChimp Product sync queued successfully'
    redirect_to admin_products_url()
  end

end
