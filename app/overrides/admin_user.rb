# NOTE: This creates a checkbox in Spree Admin that allows
# admins the ability to sign users up for MailChimp newsletters.
# For IBC, this will sign users up, but will not assign them a role.
# Further code will have to be written to acheive this.
Deface::Override.new(:virtual_path => "spree/admin/users/_form",
                     :name         => "admin_user_form_subscription",
                     :insert_after => "[data-hook=admin_user_form_fields]",
                     :partial      => "spree/admin/users/subscription_form")

Deface::Override.new(:virtual_path => "spree/admin/users/show",
                     :name         => "admin_user_show_subscription",
                     :insert_after => "table tr:last",
                     :partial      => "spree/admin/users/subscription")
