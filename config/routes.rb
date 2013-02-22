Wecool::Application.routes.draw do

  devise_for :personas
  resources :personas do
  end

  resources :mediasets, :except => [ :edit ] do
    #post 'update_photos'
  end

  controller :mediasets do
    match '/mediasets/:persona_id/view/:id' => :view, :via => :get, :as => 'view_sets' 
    match '/mediasets/:persona_id/edit/:id' => :edit, :via => :get, :as => 'edit_mediaset'
  end

  resources :photos do
    get "upload"
  end

  controller :photos do 
    match '/photos/:persona_id/view/:id' => :view, :via => :get, :as => 'photo_view'
    match '/photos/:persona_id/view/:id/exif' => :view_exif, :via => :get, :as => 'photo_view_exif'
    match '/photos/:persona_id/version/:photo_id' => :version, :via => :get, :as => 'photo_version'
    match '/photos/editor/:photo_id' => :editor, :via => :get, :as => 'photo_editor'
    match '/photos/:id/page/:page_id' => :show, :via => :get, :as => 'photo_page'
    match '/photos/:persona_id/update_setlist/:photo_id' => :update_setlist, :via => :post, 
      :as => 'photo_update_setlist'
    match '/photos/get_more/:last_id' => :get_more, :via => :get, :as => 'photo_get_more'
  end


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
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
