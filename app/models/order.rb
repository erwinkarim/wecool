class Order < ActiveRecord::Base
	# status of orders
	# 1 - created
	# 2 - waiting payment
	# 3 - items waiting to be shipped/activated
	# 4 - order complete, everything shipped and activated 
  belongs_to :persona
	validates :persona_id, :presence => true
  attr_accessible :spreedly_token_id, :status

  ORDER_STATUS_TEXT = [ 'Order Created',
    'Waiting Payment',
    'Waiting to be shipped',
    'Order Complete'
  ]
end
