Store::Application.routes.draw do
  resources :owners

  devise_for :users

  resources :users

  resources :myprops do
    collection do
      get 'details'
      get 'list_all'
#      post 'add_to_my_list'  # old method with button_to - delete
      get 'startup'
      get 'add_to_my_list'
#      get 'top'             # top is not used - should be reused or deleted 04/27/2012
#      get 'most_favorable'  # moved over to properties 05/22/2012
      get 'add_all_props'
      get 'add_prop'
      get 'remove_all_props'
      get 'remove_prop'
    end
  end
  
  resources :details

  resources :properties do
    collection do 
      get 'home'
      get 'geo_stats'
      get 'city_block'
      get 'start_search'
      post 'search'
      get 'my_block_analysis'
      get 'my_block_map'
      get 'my_block_summary'
      get 'my_block_analysis_summary'
      get 'comp_analysis_summary'
      post 'comp_analysis_summary'

      get 'comp_analysis_building_rate'
      get 'comp_block_summary'
      get 'comp_summary'
      get 'comp_block_map'
      get 'comp_map'
      get 'start_most_favorable'

      post 'most_favorable'  # not required for current most_favorable 06/03/2012
      get 'most_favorable'
      
      get 'search_most_favorable'
      get 'graph_most_favorable'
      
      get 'edit_location'
      
    end
  end
  
  resources :class_codes

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'myprops#startup'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
