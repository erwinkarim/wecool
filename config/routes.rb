Wecool::Application.routes.draw do

  devise_for :personas
  resources :personas do
    resources :jobs, :only => [:index] do
			collection do
				get 'get_more'
			end 
    end
  end

  controller :personas do
    match '/personas/:persona_id/picture' => :get_picture, :via => :get, :as => 'persona_get_profile_pic'
    match '/personas/:persona_id/picture' => :set_picture, :via => :post, :as => 'persona_update_profile_pic'
    match '/personas/get_more/:last_id' => :get_more, :via => :get, :as => 'persona_get_more'
    match '/personas/:persona_id/tags' => :tags, :via => :get , :as => 'persona_tags'
    match '/personas/:persona_id/tags/:tag_id' => :show_tag, :via => :get , :as => 'persona_show_tag'
    match '/personas/:persona_id/upgrade_to_premium' => :upgrade_acc, :via => :get, :as => 'persona_upgrade_acc'
    match '/personas/:persona_id/payment_details' => :payment_details, :via => :post, 
      :as => 'persona_payment_details'
    match '/personas/:persona_id/activities' => :activities, :via => :get, :as => 'persona_activities'
  end

  resources :mediasets, :except => [ :edit ] do
    #post 'update_photos'
  end

  controller :mediasets do
    match '/mediasets/:persona_id/view/:id' => :view, :via => :get, :as => 'view_sets' 
    match '/mediasets/:persona_id/edit/:id' => :edit, :via => :get, :as => 'edit_mediaset'
    match '/mediasets/vote/:mediaset_id/:vote_mode/by/:persona_id' => :vote, :via => :post, :as => 'mediaset_vote'
    match '/mediasets/unvote/:mediaset_id/by/:persona_id' => :unvote, :via => :post, 
      :as => 'mediaset_unvote'
    match '/mediasets/toggle_featured/:mediaset_id' => :toggle_featured, :via => :post, 
      :as => 'mediaset_toggle_featured'
    match '/mediasets/get_more/:last_id' => :get_more, :via => :get, :as => 'mediaset_get_more'
    match '/mediasets/:persona_id/not_viewable' => :not_viewable, :via => :get, :as => 'mediaset_not_viewable'
    match '/mediasets/update_attr/:id' => :update_attr, :via => :put, :as => 'mediaset_update_attr'
  end

  resources :photos, except: :new do
    get "upload"
  end

  controller :photos do 
    match '/photos/:persona_id/view/:id' => :view, :via => :get, :as => 'photo_view'
    match '/photos/:persona_id/view/:id/in/:scope/:scope_id' => :view, :via => :get, :as => 'photo_view_in_scope'
    match '/photos/:persona_id/view/:id/exif' => :view_exif, :via => :get, :as => 'photo_view_exif'
    match '/photos/:persona_id/version/:photo_id' => :version, :via => :get, :as => 'photo_version'
    match '/photos/:persona_id/transform/:photo_id/:method' => :transform, 
      :via => :post, :as => 'photo_transform'
    match '/photos/:persona_id/update_setlist/:photo_id' => :update_setlist, :via => :post, 
      :as => 'photo_update_setlist'
    match '/photos/:persona_id/editor/:photo_id' => :editor, :via => :get, :as => 'photo_editor'
    match '/photos/:persona_id/editor/:photo_id/generate' => :editor_gen, :via =>:post, :as => 'photo_editor_gen'
    match '/photos/:persona_id/editor/:photo_id/upload_to_sys' => :editor_upload_to_sys, :via => :post , 
      :as => 'photo_editor_upload'
    #match '/photos/:id/page/:page_id' => :show, :via => :get, :as => 'photo_page'
    match '/photos/get_more/:last_id' => :get_more, :via => :get, :as => 'photo_get_more'
    match '/photos/:persona_id/get_single/:photo_id' => :get_single, :via => :get, :as => 'photo_get_single'
    match '/photos/:persona_id/toggle_featured/:photo_id' => :toggle_featured, 
      :via => :post, :as => 'photo_toggle_featured'
    match '/photos/vote/:photo_id/:vote_mode/by/:persona_id' => :vote, :via => :post, :as => 'photo_vote'
    match '/photos/unvote/:photo_id/by/:persona_id' => :unvote, :via => :post, :as => 'photo_unvote'
    match '/photos/:persona_id/download/:id' => :download, :via => :post, :as => 'photo_download'
    match '/photos/:persona_id/toggle_visibility/:photo_id' => :toggle_visibility, 
      :via => :post, :as => 'photo_toggle_visibility'
    match '/photos/:persona_id/not_viewable' => :not_viewable, :via => :get, :as => 'photo_not_viewable'
    match '/photos/:persona_id/clear_from_queue/:photo_id' => :clear_from_upload_queue, :via => :post, 
      :as => 'photo_clear_queue'
    match '/photos/:persona_id/share' => :share, :via => :post, :as => 'photo_share'
    #match '/photos/download' => :download, :via => :post, :as => 'photo_download'
    match '/photos/:persona_id/dl_test' => :dl_test, :via => :get, :as => 'photos_dl_test'
    match '/photos/:persona_id/get_dups' => :get_dups, :via => :get, :as => 'photos_get_dups'
    match '/photos/:persona_id/new' => :new_direct, :via => :get, :as => 'new_photo'
    match '/photos/:persona_id/gen_s3_data' => :gen_s3_data, :via => :get, :as => 'photos_gen_s3_data'
    match '/photos/:persona_id/gen_from_s3' => :gen_from_s3, :via => :post, :as => 'photos_gen_from_s3'
    match '/photos_direct' => :create_direct, :via => :post, :as => 'photos_create_direct'
  end

  controller :followers do
    match '/followers/track/:object_type/:object_id' => :track, :via => :post, :as => 'follower_track'
    match '/followers/untrack/:object_type/:object_id' => :untrack, :via => :post, :as => 'follower_untrack'
    match '/followers/:persona_id' => :show, :via => :get, :as => 'follower'
  end

  controller :tags do
    match '/tags' => :index, :via => :get, :as => 'tags'
    match '/tags/view/:tag_id' => :show, :via => :get, :as => 'tag'
    match '/tags/get_more' => :get_more, :via => :get, :as => 'tags_get_more'
    match '/tags/related/:photo_id' => :related, :via => :get, :as => 'tag_related'
  end
  
  #for the store, purchase redeem coupons,etc
  controller :store do
    match '/store/:persona_id/add_to_cart' => :add_to_cart, :via => :post, :as => 'store_add_to_cart'
    match '/store/:persona_id/remove_from_cart/:cart_id' => :remove_from_cart, :via => :post, 
      :as => 'store_remove_from_cart'
    match '/store/:persona_id/update_cart_item/:cart_id' => :update_cart_item, :via => :put, 
      :as => 'store_update_cart_item'
    match '/store/:persona_id/redeem_coupon' => :redeem_coupon, :via => :post, :as => 'store_redeem_coupon'
    match '/store/:persona_id/checkout' => :checkout,:via => :get, :as => 'store_checkout'
    match '/store/:persona_id/confirming_payment' => :confirm_pay, :via => :get, :as => 'store_confirm_pay'
    match '/store/:persona_id/confrimed_payment/:order_id' => :confirmed_pay, :via => :get, 
      :as => 'store_confirmed_pay'
    match '/store/:persona_id/generate_order' => :generate_order, :via => :post, :as => 'store_generate_order'
    match '/store/:persona_id/orders' => :orders, :via => :get, :as => 'store_orders'
    match '/store/:persona_id/past_orders' => :past_orders, :via => :get, :as => 'store_past_orders'
    match '/store/:persona_id/order_detail/:order_id' => :order_detail, :via => :get, :as => 'store_order_detail'
    match '/store/:persona_id/order_detail/:order_id/:cart_id' => :cart_detail, :via => :get, :as => 'store_cart_detail'
    match '/store/:persona_id/coupons' => :coupons, :via => :get, :as => 'store_coupons'
  end

	
	controller :static_page do 
		match '/static/tour' => :tour, :via => :get, :as => 'tour'
		match '/static/tour/about_wecool' => :'tour/about_wecool', :via => :get, :as =>'about_wecool' 
		match '/static/tour/online_editing' => :'tour/online_editing', :via => :get, :as =>'online_editing' 
		match '/static/tour/organize_photo' => :'tour/organize_photo', :via => :get, :as =>'organize_photo' 
		match '/static/aboutUs' => :aboutUs, :via => :get, :as => 'aboutUs'
		match '/static/termsAndConditions' => :termsAndConditions, :via => :get, :as => 'termsAndConditions'
		match '/static/browser_unsupported' => :browser_unsupported, :via => :get, :as => 'browser_unsupported'
		match '/static/feedback' => :feedback, :via => :post, :as => 'get_feedback'
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
