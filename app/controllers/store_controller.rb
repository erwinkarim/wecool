class StoreController < ApplicationController
  before_filter :require_login

  #ensure that the users are logging in before accessing the store
  def require_login
    unless persona_signed_in? 
      flash[:error] = "You must sign in first"
      redirect_to new_persona_session_path
    end 
  end

  #explain about the the store workflow
  #

  #add items to cart
  # POST   /store/:persona_id/add_to_cart(.:format)
	# mandatory arguemnts:-
	#		sku_code: Sku.code item to be added
	# optional arguments:-
	#		cart_quantity: number of items of the sku will be bought	
  def add_to_cart
		@sku = Sku.where(:code => params[:sku_code] ).first	
		respond_to do |format|
			if @sku.nil? then
				format.js { redirect_to :status => 404 } 
			else
				@persona = Persona.where( :screen_name => params[:persona_id]).first
				@cart = @persona.carts.new( :item_type => @sku.model, :item_sku => @sku.code)
				if @cart.save! then
					format.js
				else
					format.js { redirect_to :status => 500 }
				end
			end
		end 
  end
  
  #remove items from cart
  #POST   /store/:persona_id/remove_from_cart(.:format)                    
	# expected arguments
	# :cart_id		=> the cart record that we want to delete
  def remove_from_cart
		@persona = Persona.where(:screen_name => params[:persona_id]).first
		@cart = @persona.carts.find(params[:cart_id])
		
		respond_to do |format|
			if @cart.nil? then
				flash[:error] = 'Unable to find cart item'
			else
				if @cart.destroy then
					@new_total_amount = @persona.carts.map{ |x| Sku.find(x.item_id).base_price * x.quantity }.sum 
				else
					flash[:error] = 'Unable to delete cart item'
				end
			end
			format.js	
		end
				
  end

	#PUT    /store/:persona_id/update_cart_item(.:format)
	# update cart item
	# expected arguments:-
	#		:cart_id, the cart record for we wish to update
	def update_cart_item
		@persona = Persona.where(:screen_name => params[:persona_id]).first
		@cart = @persona.carts.find(params[:cart_id])
		respond_to do |format|
			if @cart.update_attributes(params[:cart]) then
				format.json { respond_with_bip @cart }
			else
				format.json { respond_with_bip @cart }
			end
		end
	end

  # redeem coupons that is purchased else where
  #  POST   /store/:persona_id/redeem_coupon(.:format)
  #  expected arguements
  #   :redeemCodes    the coupon code
  def redeem_coupon
    @coupon_code = params[:redeemCodes]

    #check if the coupon is valid and not taken
    @coupon = Coupon.where(:code => params[:redeemCodes]).first
    coupon_failure = false
    if @coupon.nil? then
      message = 'Coupon not found'
      coupon_failure = true
    elsif !@coupon.redeem_date.nil? then
      if @coupon.persona_id == current_persona.id then
        message = 'You already redeem this coupon on ' + I18n.l(@coupon.redeem_date)
      else 
        message = 'Coupon has been taken by someone else'
      end
      coupon_failure = true
    end

    #if everything ok then update the coupon to be redeem
    unless coupon_failure 

      #update coupon
      @persona = Persona.where(:screen_name => params[:persona_id]).first
      @coupon.update_attributes({ :persona_id => @persona.id, :redeem_date => DateTime.now } )

			#get the powers that coupon have and do the necessary adjustments that each coupon gives
			YAML::load(@coupon.sku.power).each_pair do |key,value|
				if key == :premium then
					if @coupon.sku.code = 'member1y' then 
						duration = 1.year
					elsif @coupon.sku.code = 'member2y' then
						duration = 2.year
					end

					#update persona
					@persona.photos.update_all(:system_visible => true)

					#update persona premiumness
					@persona.update_attributes( { :premium => true })
					if @persona.premiumSince.nil? then
						@persona.update_attributes( { :premiumSince => DateTime.now } )
					end
					if @persona.premiumExpire.nil? || @persona.premiumExpire < DateTime.now then
						@persona.update_attributes( {:premiumExpire => DateTime.now + duration })
					else
						@persona.update_attributes( { :premiumExpire => @persona.premiumExpire + duration })
					end
					@persona.save
				elsif key == :storage then
					@persona.check_storage		
				elsif key == :duration_when_activated then
					@coupon.update_attribute( :expire_date, Time.at(DateTime.now.to_f + value) )
				end
			end

      #if there orders/carts associated with this coupon, update order/cart status to complete if every coupon
      # in the order has been activited
      cart = Cart.where( :item_type => 'coupon', :item_id => @coupon.id).first
      if !cart.nil? then
        cart.update_attribute(:status, 2 )
        cart.update_attribute(:status, 5 )
        Order.find(cart.order_id).update_order_status
      end

    end

    if coupon_failure then 
      respond_to do |format|
        format.html { redirect_to :back, alert: message }
      end
    else
      respond_to do |format|
        format.html
      end
    end

  end

  #store checkout confirming your order before generating new order
  #GET    /store/:persona_id/checkout(.:format) 
  def checkout
    @persona = Persona.where( :screen_name => params[:persona_id]).first
		@carts = @persona.carts.where :order_id => nil
  end

  #generate order before asking for payment
  #POST   /store/:persona_id/generate_order(.:format)                      
  def generate_order
    @persona = Persona.where( :screen_name => params[:persona_id]).first

		@carts = @persona.carts.where(:order_id => nil)

		@order = @persona.orders.new(:status  => 0)

		respond_to do |format|
			if @order.save! then
				@carts.each do |cart_item|
					cart_item.update_attribute(:order_id, @order.id)
				end
        #after the order is created, await for payment
        @order.update_attribute(:status, 1)
				format.js
			else
				flash[:error] = 'Unable to place order'
				format.js :status => 500
			end 
		end
  end

  #asking for payment, mostly form to fill up CC info
  #GET    /store/:persona_id/confirming_payment(.:format)                  
  # optional arguements :-
  #   order_id          this if for a specific order, otherwise it will show for the last order
  def confirm_pay
    @persona = Persona.where( :screen_name => params[:persona_id]).first
    @orders = @persona.orders
    if params.has_key? :order_id then
      @current_order = @persona.orders.find(params[:order_id])
    else
      @current_order = @persona.orders.last
    end
		@order = @current_order
    @carts = @persona.carts.where( :order_id => @current_order.id)

		respond_to do |format|
			format.html
		end
  end


  #the payment is confirmed or rejected. display the result
  # GET    /store/:persona_id/confrimed_payment/:order_id(.:format)
	#expected options
	#		:error => error message
	#		:token => payment token if the payment is successful
  def confirmed_pay
    @persona = Persona.where( :screen_name => params[:persona_id]).first

    if params[:error] then
      flash[:error] = params[:error]
    else
      @order = @persona.orders.find(params[:order_id])
    
      @payment_ok = false

      #check if the payment goes through or not...
			token=params[:token]

			#valid the payment here, if ok, go next step where the order has been done
			#otherwise, if got some other error, check and go back to cofirm_pay action
			#payment_method = SpreedlyCore::PaymentMethod.find(token)
      env = Spreedly::Environment.new(ENV['SPREEDLYCORE_ENVIRONMENT_KEY'],ENV['SPREEDLYCORE_ACCESS_SECRET'])
      payment_method = env.find_payment_method(token)

			if payment_method.valid? then
        @amount_charge = Cart.where( 
          :order_id => params[:order_id] 
        ).map{ 
          |x| Sku.where(:code => x.item_sku).first.base_price * x.quantity * 100
        }.sum
        purchase_transaction = env.authorize_on_gateway(ENV['SPREEDLYCORE_GATEWAY_TOKEN'], token, @amount_charge ) 
        respond_to do |format|
          if purchase_transaction.succeeded? then 
            @payment_ok = true
	
						#process the order
            #if sku is membership or online stuff, create the broucher and ask if wants to active it
						Cart.where(:order_id => params[:order_id]).each do |cart_item|
							#so far this store only do online stuff for now
							sku = Sku.where(:code => cart_item.item_sku).first
							coupon = Coupon.generate_coupon( @persona.id, sku.id)
							#need to account for multiple items
							cart_item.update_attribute( :item_id, coupon.id)
						end 
						@order.update_attributes({ :status =>  2, :spreedly_token_id => params[:token] })
            format.html 
          else
            redirect_to store_confirm_pay_path(@persona.screen_name, 
              :order_id => params[:order_id]), :error => 'Unable to charge you CC' 
          end
        end #respond_to ...
			else
				#redirect to confirm_pay with errors
				redirect_to store_confirm_pay_path(@persona.screen_name, 
          :order_id => params[:order_id]), :error => payment_method.errors.join('\n')
			end
    end
  end

  #GET    /store/:persona_id/orders(.:format)                              
  # get current orders
  def orders
		@persona = Persona.where( :screen_name => params[:persona_id]).first
    #only show incomplete orders
		@orders = @persona.orders.where{ (status != 3) }

		respond_to do |format|
			format.html
		end
  end

	#GET    /store/:persona_id/past_orders(.:format
	#get past orders
	def past_orders
		@persona = Persona.where( :screen_name => params[:persona_id]).first
		@orders = @persona.orders

    respond_to do |format|
      format.html 
      format.json { render json: @orders }
      format.xml { render xml: @orders }
    end
	end

	# GET    /store/:persona_id/order_detail/:order_id
	#get order detail
	def order_detail
		@persona = Persona.where( :screen_name => params[:persona_id]).first
		@order = @persona.orders.find( params[:order_id] )
	
		respond_to do |format|
			if @order.nil? then
				format.html :status => 404
			else
        screen_name = @persona.screen_name
        order_id = @order.id
        @carts = @order.carts
        @order_activity = Version.where{ 
          (item_type.eq 'Order') & (item_id.eq order_id)
        }.reverse

        #get the coupons associated with this order
        @coupons = Coupon.where(:id => @carts.where( :item_type => 'coupon').pluck(:item_id) ) 

				format.html
        format.json{ render json: @coupons }
			end
		end
	end

	#GET    /store/:persona_id/order_detail/:order_id/:cart_id(.:format)
	#get details about the cart
	def cart_detail
		@persona = Persona.where( :screen_name => params[:persona_id]).first
		@order = @persona.orders.find( params[:order_id] )

		unless @order.nil?
			@cart = @order.carts.find(params[:cart_id])
			cart_id = @cart.id
			@cart_activity = Version.where{ 
				(item_type.eq 'Cart') & (item_id.eq cart_id)
			}.reverse
		end

	end
 
  # GET    /store/:persona_id/coupons 
  #display the coupons that this guy has
  def coupons
		@persona = Persona.where( :screen_name => params[:persona_id]).first
    @coupons = @persona.coupons.reverse

    respond_to do |format|
      format.html
      format.json { render json: @coupons }
    end
  end
end
