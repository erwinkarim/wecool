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
    :exclusion => { 
      :in => %w(new vote unvote get_more download), :message => 'You cannot use reserved word %{value}'
    }
  validates_acceptance_of :agreeToTNC, :allow_nil => false, :accept=> true
  has_many :photos,:dependent=> :destroy
  has_many :mediasets, :dependent => :destroy
  has_many :followers, :dependent => :destroy
  has_many :coupons, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  has_many :orders, :dependent => :destroy

	#allow for voting
  make_voter

  def tracks ( object_type, object_id) 
    return !self.followers.find(:all, :conditions => 
      { :tracked_object_type => object_type, :tracked_object_id => object_id}).empty?  
  end

  def crop ( x_coor, y_coor, h_coor, w_coor )
    #cache the avatar because of fog
    if !avatar.cached? then
      avatar.cache_stored_file!
      avatar.retrieve_from_cache! avatar.cache_name
    end
    
    #corp the image and recreate versions
    image = Magick::ImageList.new(avatar.current_path)
    cropped_image = image.crop(x_coor, y_coor, h_coor, w_coor)
    cropped_image.write(avatar.current_path)
  
    avatar.recreate_versions!
    save!
  end
  
  #calculate bandwith usage for the current calender month (ie; 1st to current day)
  def bandwidth_usage
    bandwidth = self.photos.where{ created_at.gt Date.today.at_beginning_of_month }.map{ |p| p.avatar.size }.sum
    return bandwidth
  end

  # gather activity of this persona
	# returns an array of activities. each element is a cluster of activities within the :cluster_interval
	#	each element should look like this:-
	#	{
	#		:first_activity									when the first activity took place
	#		:last_activity									when the last activity took place
	#		:activities => [	
	#			{ :item_id, :item_type, :events => [  { :event, :count}, .., { :event, :count}  ] }	,
	#			...	
	#			{ :item_id, :item_type, :events => [  { :event, :count}, .., { :event, :count}  ] }
	#		]
	#	}
	#	 default options are:-
	#	 :begin_date        the start of the date
	#	 :date_length       how long the activity
	#	 :cluster_interval  spacing of time between clusters of activity. default is 5 minutes which means
	#	                    that distance between each cluster will be at least 5 minutes.
  def get_activity new_options = {} 
    options = { :begin_date => nil, :date_length => 1.month, :cluster_interval => 5.minutes }
    options = options.merge(new_options)
    myScreenName = self.screen_name
    #if begin_date is not set, limit to 1 month or earlier
    begin_date = new_options.has_key?(:begin_date) ? new_options[:begin_date] : 
      (
        Version.where{ whodunnit.eq myScreenName }.max.nil? ? 
        1.month.ago : Version.where{ whodunnit.eq myScreenName }.max.created_at
      )
    date_length = options[:date_length]
  
    cluster = Array.new      
    Version.where{ (whodunnit.eq myScreenName) & (created_at.lt begin_date) & 
      (created_at.gt begin_date - date_length ) }.order('created_at').
    each do |e|
			theEvent = e.event
      if cluster.empty? || cluster.last[:last_activity] + 5.minutes < e.created_at then 
        cluster << { :first_activity => e.created_at, :last_activity => e.created_at , 
          :activities => [
						{ :item_type => e.item_type, :item_id => e.item_id,  :events => [{ :event => theEvent, :count => 1 }] }
					] 
        }
      else
				#go through the cluster, find the item id and update the events
				handle = cluster.last
				if handle[:activities].map{ 
          |x| x[:item_type] == e.item_type && x[:item_id] == e.item_id 
        }.inject{ |x,y| x||y } then
					#the item is in the handle, look if the event is new or old
					handle[:activities].map{ |x| 
						if x[:item_type] == e.item_type && x[:item_id] == e.item_id then
							if x[:events].map{ |x| x[:event] == theEvent }.inject{ |x,y| x||y } then
								#event is old, find it and add count to +1
								x[:events].map{ |x|
									if x[:event] == theEvent then
										x[:count] = x[:count] + 1
									end
								}
							else
								x[:events] << { :event => theEvent, :count => 1 }
							end
						end
					}
				else
					#the item is not in the handle, add new activities
					handle[:activities] <<  { 
						:item_type => e.item_type, :item_id => e.item_id,  :events => [{ :event => theEvent, :count => 1 }] 
					}
				end
      end
    end

    return cluster.sort_by{ |e| -(e[:first_activity].to_i) }
  end
end
