# encoding: utf-8
LibraryApp::Application.routes.draw do
  root to: 'default#home'
  
  resources :books do
    collection do
      get 'library'
    end
    member do
      post 'borrow'
      post 'order'
    end
  end


  resources :users do   
    collection do
      delete 'logout'
      get 'login'
    end
    member do
      get 'reset'
    end
  end
  
  #match '/library', to: 'books#new_hot', via: 'get'
  
  #match '/borrow', to: 'books#borrow', via: 'post'
  match '/borrowing', to: 'books#borrow_current', via: 'get'
  match '/borrowed', to: 'books#borrow_history', via: 'get'
  
  #match '/order', to: 'books#order', via: 'post'
  match '/ordering', to: 'books#order_current', via: 'get'
  match '/ordered', to: 'books#order_history', via: 'get'
  
  match '/recommend_list', to: 'books#recommed_list', via: 'get'
  match '/recommend', to: 'books#recommend', via: 'post'
  match '/recbook', to: 'books#recbook', via: 'get'
  match '/fetch', to: 'books#fetch', via: 'get'
  match '/vote', to: 'books#vote', via: 'post'
  
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
