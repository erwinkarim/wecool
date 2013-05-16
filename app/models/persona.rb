require 'carrierwave/orm/activerecord'
class Persona < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me ,:realname, :screen_name, 
    :avatar, :agreeToTNC, :premium, :premiumSince, :premiumExpire
  mount_uploader :avatar, PersonaUploader
  validates :screen_name, :presence => true, :uniqueness => true, 
    :format => {:with => /[[:alnum:]]+/, :on => :create, :messsage=>'Only alphanumeric' }, 
    :exclusion => { :in => %w(new vote unvote get_more), :message => 'You cannot use reserved word %{value}'}
  validates_acceptance_of :agreeToTNC, :allow_nil => false, :accept=> true
  has_many :photos,:dependent=> :destroy
  has_many :mediasets, :dependent => :destroy
  has_many :followers, :dependent => :destroy
  has_many :coupons, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  make_voter

  def tracks ( object_type, object_id) 
    return !self.followers.find(:all, :conditions => 
      { :tracked_object_type => object_type, :tracked_object_id => object_id}).empty?  
  end

  def crop ( x_coor, y_coor, h_coor, w_coor )
    #corp the image and recreate versions
    image = Magick::ImageList.new(avatar.current_path)
    cropped_image = image.crop(x_coor, y_coor, h_coor, w_coor)
    cropped_image.write(avatar.current_path)
  
    avatar.recreate_versions!
  end
  
  #calculate bandwith usage for the current calender month (ie; 1st to current day)
  def bandwidth_usage
    bandwidth = self.photos.where{ created_at.gt Date.today.at_beginning_of_month }.map{ |p| p.avatar.size }.sum
    return bandwidth
  end
end
