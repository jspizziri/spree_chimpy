Spree::Core::Engine.add_routes do
  get 'admin/chimpy/orders/push', to: 'admin/orders#push_all_to_mail_chimp', as: 'mail_chimp_push_orders'

  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
  end
end
