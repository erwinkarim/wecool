class Coupon < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :code, :expire_date, :redeem_date
end
