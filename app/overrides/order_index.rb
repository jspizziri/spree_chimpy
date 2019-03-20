Deface::Override.new(:virtual_path => "spree/admin/orders/index",
                     :name         => "order_index_buttons",
                     :insert_after => "erb:contains('page_actions')",
                     text: "<%= link_to('Sync with MailChimp', mail_chimp_push_orders_path(), class: 'btn btn-primary') %>"
                   )
