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
  
  #calculate storage usage for user
  def storage_usage
    storage = self.photos.map{ |p| p.avatar.size }.sum
    return storage
  end

  # gather activity of this persona
	# returns an array of activities. each element is a cluster of activities within the :cluster_interval
	#	each element should look like this:-
	#	{
	#		:first_activity									when the first activity took place
	#		:last_activity									when the last activity took place
	#		:activities => {
	#		  :<item_type1> => { 
	#		    :id => [id1, .. , idn], 
	#		    :events => { :<event_type1> => event_count1, .. , :<event_typeN> => event_countN  }  
	#		  }
	#		}
	#	}
	#	 default options are:-
	#	 :begin_date        the start of the date, must be integer of seconds since epoch
	#	 :date_length       how long the activity
	#	 :cluster_interval  spacing of time between clusters of activity. default is 5 minutes which means
	#	                    that distance between each cluster will be at least 5 minutes.
  def get_activity new_options = {} 
    options = { :begin_date => nil, :date_length => 1.month, :cluster_interval => 5.minutes }
    options = options.merge(new_options)
    myScreenName = self.screen_name
    date_length = options[:date_length]

    #check if there's any activity at begin_date - date_length, 
    # if no activity, get the most recent date before begin_date
		# also if there's no activity before the begin date, then just return nil
    if new_options.has_key? :begin_date then
			begin_date = Time.at( new_options[:begin_date].to_i )
			recent_act = Version.where{ (whodunnit.eq myScreenName) & (created_at.lteq begin_date) & 
        (item_type.eq 'Photo') }.max
			if recent_act.nil? then
				return nil
			else
				recent_date = recent_act.created_at
			end
      begin_date = recent_date < begin_date - date_length ? recent_date  : begin_date
    else
        begin_date = Version.where{ whodunnit.eq myScreenName }.max.created_at
    end
  
    cluster = Array.new      
    Version.where{ (whodunnit.eq myScreenName) & (created_at.lteq begin_date) & 
      (created_at.gt begin_date - date_length ) & (item_type.eq 'Photo') }.order('created_at').
    each do |e|
      #skip it if the object no longer exists
      next if eval(e.item_type).where(:id => e.item_id).empty? 

			theEvent = e.event
      if cluster.empty? || cluster.last[:last_activity] + 5.minutes < e.created_at then 
        cluster << { :first_activity => e.created_at, :last_activity => e.created_at , 
          :activities => { 
              e.item_type.to_sym => { 
                :id => [e.item_id], :events => { theEvent.to_sym => 1 }, 
                :handle => [ eval(e.item_type).find(e.item_id) ],   
              }
          } 
        }

      else
				#go through the cluster, see if the object class existed before, then add to the id and event log
				# otherwise, just create a new object
				handle = cluster.last
        if handle[:activities].has_key? e.item_type.to_sym then
          #item is here, get for id and proper activities
          if !handle[:activities][e.item_type.to_sym][:id].include? e.item_id then
            handle[:activities][e.item_type.to_sym][:id] << e.item_id 
            handle[:activities][e.item_type.to_sym][:handle] << eval(e.item_type).find(e.item_id)
          end

          #add if the event is already here, otherwise new event  
          if handle[:activities][e.item_type.to_sym][:events].has_key? theEvent.to_sym then
            handle[:activities][e.item_type.to_sym][:events][theEvent.to_sym] += 1 
          else
            handle[:activities][e.item_type.to_sym][:events] = 
              handle[:activities][e.item_type.to_sym][:events].merge( { theEvent.to_sym => 1 })
          end
        else
          #item is not here, new item and activities
          handle[:activities] =  handle[:activities].merge({ 
              e.item_type.to_sym => { 
                :id => [e.item_id], :events => { theEvent.to_sym => 1 }, 
                :handle => [ eval(e.item_type).find(e.item_id)]
              }
          })
        end
      end
    end #each

    return cluster.sort_by{ |e| -(e[:first_activity].to_i) }
  end
    
  #check current storage space
  # default is 5, which means 5GB
  def current_storage_size
    #check current active coupons, sum up storage
		paid_storage = self.coupons.where{ ( redeem_date.lt DateTime.now) & (expire_date.gt DateTime.now)}.map{ |x| YAML::load(x.sku.power)[:storage] }.sum
    return (paid_storage + 5) *1000*1000*1000
  end
end
