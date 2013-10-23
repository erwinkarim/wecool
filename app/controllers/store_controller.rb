class StoreController < ApplicationController
  before_filter :require_login

  #ensure that the users are logging in before accessing the store
  def require_login
    unless persona_signed_in? 
      flash[:error] = "You must sign in first"
      redirect_to new_persona_session_path
    end 
  end

  #add items to cart
  # POST   /store/:persona_id/add_to_cart(.:format)
  def add_to_cart
    
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
  def checkout
  end

  #generate order before asking for payment
  #POST   /store/:persona_id/generate_order(.:format)                      
  def generate_order
  end

  #asking for payment
  #GET    /store/:persona_id/confirming_payment(.:format)                  
  def confirm_pay
  end

  #GET    /store/:persona_id/orders(.:format)                              
  # get current orders
  def orders
  end
end
