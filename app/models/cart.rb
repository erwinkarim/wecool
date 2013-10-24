class Cart < ActiveRecord::Base
  belongs_to :persona
	belongs_to :order
  attr_accessible :item_id, :item_sku, :item_type
end
