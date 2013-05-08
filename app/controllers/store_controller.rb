class StoreController < ApplicationController

  #add items to cart
  # POST   /store/:persona_id/add_to_cart(.:format)
  def add_to_cart
    
  end

  # redeem coupons that is purchased else where
  #  POST   /store/:persona_id/redeem_coupon(.:format)
  def redeem_coupon
    @coupon_code = params[:redeemCodes]
  end
end
