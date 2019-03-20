Spree::Admin::OrdersController.class_eval do

  # Adds the ability to manually queue all orders with at least one line item to
  # sync with MailChimp. This is designed to serve two purposes:
  #
  #       1.  It provides a manual override that can push order/cart data into MailChimp
  #           for data that existed BEFORE this integration was added to Spree
  #
  #       2.  It can be used to perform a bulk sync if the automated process needs to be
  #           turned off for any reason
  def push_all_to_mail_chimp
    Spree::Order.where.not(item_count: 0).each do |order|
      order.notify_mail_chimp
    end

    flash[:success] = 'MailChimp sync queued successfully'
    redirect_to admin_orders_url()
  end

end
