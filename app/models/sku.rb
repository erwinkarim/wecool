#sku to store the unit description and codes
# model is which table that will reference to
#  and will be accessed via eval(Sku.model.titlecase)
class Sku < ActiveRecord::Base
  attr_accessible :code, :description, :model, :base_price
  validates :code, :uniqueness => true
  validates :model, :presence => true
end
