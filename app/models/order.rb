class Order < ActiveRecord::Base
  belongs_to :persona
	validates :persona_id, :presence => true
  attr_accessible :spreedly_token_id, :status

  #ensure paper trail
  has_paper_trail 

  #order status text t
	# status of orders
	# 1 - created
	# 2 - waiting payment
	# 3 - items waiting to be shipped/activated
	# 4 - order complete, everything shipped and activated 
  ORDER_STATUS_TEXT = [ 'Order Created',
    'Waiting Payment',
    'Waiting to be shipped',
    'Order Complete'
  ]
end
