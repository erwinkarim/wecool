class Order < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :spreedly_token_id, :status
end
