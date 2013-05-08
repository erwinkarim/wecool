class Cart < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :item_id, :item_sku, :item_type
end
