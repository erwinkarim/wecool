class Coupon < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :code, :expire_date, :redeem_date, :persona_id
  validates :code, :presence => true, :uniqueness => true
  before_validation :generate_code

  #generate the codes before validation
  def generate_code
    self.code = loop do 
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Coupon.where(code: random_token).exists?
    end
  end
end
