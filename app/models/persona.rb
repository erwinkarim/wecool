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
    options = { :begin_date => DateTime.now, :date_length => 1.month, :cluster_interval => 5.minutes }
    options.merge(new_options)
    cluster = Array.new      
  
    myScreenName = self.screen_name
    Version.where{ (whodunnit.eq myScreenName) & (created_at.lt options[:begin_date]) & 
      (created_at.gt options[:begin_date] - options[:date_length] ) }.order('created_at').
    each do |e|
      #this will be simplied on paper_trail 2.7.2
      theEvent = (e.item_type == 'Photo' || e.item_type == 'Mediaset' ) && 
        e.event == 'update' && e.changeset[:featured] == [false,true] ? 'featured' : e.event 
      theEvent = (e.item_type == 'Photo' || e.item_type == 'Mediaset' ) && 
        e.event == 'update' && e.changeset.has_key?(:up_votes) ? 'up_votes' : theEvent
      theEvent = (e.item_type == 'Photo' || e.item_type == 'Mediaset' ) && 
        e.event == 'update' && e.changeset.has_key?(:tag_list) ? 'update_tags' : theEvent
      if cluster.empty? || cluster.last[:last_activity] + 5.minutes < e.created_at then 
        cluster << { :first_activity => e.created_at, :last_activity => e.created_at , 
          :activity => [{ :item => e.item_type, :event => theEvent, :count => 1 , :id => [e.item_id] }] 
        }
      else
        #case where this item is created within options[:cluster_interval]     
        cluster.last[:last_activity] = e.created_at
        act = cluster.last[:activity].select{ |act| act[:item] == e.item_type && act[:event] == theEvent }.first
        act.nil? ? 
          cluster.last[:activity] << { :item => e.item_type, :event => theEvent, :count => 1 , :id => [e.item_id] } : 
          begin 
            if !act[:id].include? e.item_id then
              act[:count] += 1
              act[:id] << e.item_id
            end
          end
      end
    end

    return cluster.sort_by{ |e| -(e[:first_activity].to_i) }
  end
end
