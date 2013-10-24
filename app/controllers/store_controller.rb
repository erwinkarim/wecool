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
		sku = Sku.where(:code => params[:sku_code] ).first	
		respond_to do |format|
			if sku.nil? then
				format.js { flash[:warning] = 'Item not found' }
			else
				format.js
			end
		end 
  end
  
  #remove items from cart
  #POST   /store/:persona_id/remove_from_cart(.:format)                    
  def remove_from_cart
  end

  # redeem coupons that is purchased else where
  #  POST   /store/:persona_id/redeem_coupon(.:format)
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
    if !coupon_failure then

      #update coupon
      @persona = Persona.where(:screen_name => params[:persona_id]).first
      @coupon.update_attributes({ :persona_id => @persona.id, :redeem_date => DateTime.now } )
      if @coupon.sku.code = '1ypm' then 
        duration = 1.year
      elsif @coupon.sku.code = '2ypm' then
        duration = 2.year
      end

      #update persona
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

      #update persona
      @persona.photos.update_all(:system_visible => true)

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
  end

  #generate order before asking for payment
  #POST   /store/:persona_id/generate_order(.:format)                      
  def generate_order
    @persona = Persona.where( :screen_name => params[:persona_id]).first
  end

  #asking for payment, mostly form to fill up CC info
  #GET    /store/:persona_id/confirming_payment(.:format)                  
  def confirm_pay
    @persona = Persona.where( :screen_name => params[:persona_id]).first
  end


  #the payment is confirmed or rejected. display the result
  #GET    /store/:persona_id/confrimed_payment(.:format)
	#expected options
	#		:error => error message
	#		:token => payment token if the payment is successful
  def confirmed_pay
    if params[:error] then
      flash[:error] = params[:error]
    else
      @persona = Persona.where( :screen_name => params[:persona_id]).first
      #check if the payment goes through or not...
			
			token=params[:token]

			#valid the payment here, if ok, go next step where the order has been done
			#otherwise, if got some other error, check and go back to cofirm_pay action
	
			payment_method = SpreedlyCore::PaymentMethod.find(token)
			if payment_method.valid? then
				flash[:info] = 'Valid Card, start charging'	
			else
				#redirect to confirm_pay with errors
				redirect_to confrim_pay_path(@persona.screen_name), :error => payment_method.errors.join('\n')
			end
			
    end
  end

  #GET    /store/:persona_id/orders(.:format)                              
  # get current orders
  def orders
  end
end
