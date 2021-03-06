class Coupon < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :expire_date, :redeem_date, :persona_id, :sku_id
  attr_readonly :code
  validates :code, :uniqueness => true
  validates :sku, :presence => true
  before_create :generate_code
  belongs_to :sku

  #generate the codes before validation
  def generate_code
    self.code = loop do 
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Coupon.where(code: random_token).exists?
    end
  end

	#create a new coupon based on persona_id, item sku
	def self.generate_coupon persona_id, sku_id
		persona = Persona.find persona_id
		coupon = persona.coupons.new( :sku_id => sku_id )
		coupon.save!
		return coupon
	end
end
