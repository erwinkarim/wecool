class Cart < ActiveRecord::Base
  belongs_to :persona
	belongs_to :order
	
	#a cart item needs to belong to a persona
	validates :persona_id, :presence => true
  attr_accessible :item_id, :item_sku, :item_type, :quantity, :status

  after_initialize :init
 
  CART_STATUS_TEXT = [ 'Cart Created',
    'Coupon Generated',           #1
    'Coupon Redeemed',            #2
    'Waiting to be Shipped',      #3
    'Shipped',                    #4
    'Complete'                    #5
  ] 
  def init
    self.status ||= 0
  end
end
