require 'carrierwave/orm/activerecord'
class Persona < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_paper_trail

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

  # gather activity of this persona
  def get_activity new_options = {} 
    options = { :last_date => 1.month.ago, :cluster_interval => 5.minutes }
    options.merge(new_options)
    cluster = Array.new      
    self.photos.where{ created_at.gt options[:last_date] }.order('created_at desc').each do |e|
      if cluster.empty? then
       cluster = [{:type => 'photo', :items => [e] , :first_activity => e.created_at}]
      else
        cluster.last[:items].last.created_at < e.created_at + options[:cluster_interval] ? 
          cluster.last[:items] << e : 
          cluster << { :type => 'photo', :items => [e], :first_activity => e.created_at } 
      end
    end

    self.mediasets.where{ updated_at.gt options[:last_date] }.order('updated_at desc').each do |e|
      cluster << { :type => 'mediaset', :items => [e], :first_activity => e.updated_at }       
    end

    return cluster.sort_by{ |e| -(e[:first_activity].to_i) }
  end
end
