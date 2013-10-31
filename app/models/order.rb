class Order < ActiveRecord::Base
  belongs_to :persona
	validates :persona_id, :presence => true
  attr_accessible :spreedly_token_id, :status
  after_initialize :init

  #ensure paper trail
  has_paper_trail 

  #order status text t
	# status of orders
	# 0 - created
	# 1 - waiting payment
	# 2 - items waiting to be shipped/activated
	# 3 - order complete, everything shipped and activated 
  ORDER_STATUS_TEXT = [ 'Order Created',
    'Waiting Payment',
    'Waiting to be shipped',
    'Order Complete'
  ]

  def init
    self.status ||= 0
  end

  #recheck each of the cart status, and set to 'order complete' if it's done
  def update_order_status
    carts = Cart.where(:order_id => self.id)
    order_complete = true

    #go through the cart to check state of carts
    carts.each do |cart|
      if cart.status !=  5 then
        order_complete = false
        break
      end  
    end

    if order_complete then
      self.update_attribute( :status, 3) 
    end

    return order_complete
  end
end
