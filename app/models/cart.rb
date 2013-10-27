class Cart < ActiveRecord::Base
  belongs_to :persona
	belongs_to :order
	
	#a cart item needs to belong to a persona
	validates :persona_id, :presence => true
  attr_accessible :item_id, :item_sku, :item_type, :quantity
end
