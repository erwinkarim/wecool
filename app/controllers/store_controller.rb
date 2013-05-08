class StoreController < ApplicationController

  #add items to cart
  # POST   /store/:persona_id/add_to_cart(.:format)
  def add_to_cart
    
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
      message = 'Coupon has been taken by '+ Persona.find(@coupon.persona_id).first.screen_name
      coupon_failure = true
    end

    #if everything ok then update the coupon to be redeem
    if !coupon_failure then
      @persona = Persona.where(:screen_name => params[:persona_id]).first
      @coupon.update_attributes({ :persona_id => @persona.id, :redeem_date => DateTime.now } )
      @persona.update_attributes( { :premium => true })
      if @persona.premiumSince.nil? then
        @persona.update_attributes( { :premiumSince => DateTime.now } )
      end
      if @persona.premiumExpire.nil? then
        @persona.update_attributes( {:premiumExpire => DateTime.now + 1.year })
      else
        @persona.update_attributes( { :premiumExpire => @persona.premiumExpire + 1.year })
      end

      @coupon.save
      @persona.save
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
end
