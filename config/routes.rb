LibraryApp::Application.routes.draw do
  root to: 'default#home'
  
  resources :book
  
  match '/users', to: 'user#index', via: 'get'
  match '/add_user', to: 'user#create', via: 'post'
  match '/delete_user', to: 'user#delete', via: 'post'
  match '/modify_user', to: 'user#modify', via: 'post'
  
  match '/newhot', to: 'book#new_hot', via: 'get'
  
  match '/borrow', to: 'book#borrow', via: 'post'
  match '/borrowing', to: 'book#borrow_current', via: 'get'
  match '/borrowed', to: 'book#borrow_history', via: 'get'
  
  match '/order', to: 'book#order', via: 'post'
  match '/ordering', to: 'book#order_current', via: 'get'
  match '/ordered', to: 'book#order_history', via: 'get'
  
  match '/recommend_list', to: 'book#recommed_list', via: 'get'
  match '/recommend', to: 'book#recommend', via: 'post'
  match '/recbook', to: 'book#recbook', via: 'get'
  match '/fetch', to: 'book#fetch', via: 'get'
  match '/vote', to: 'book#vote', via: 'post'
  
  match '/login', to: 'user#login', via: 'get'
  match '/signout', to: 'user#destroy', via: 'delete'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
