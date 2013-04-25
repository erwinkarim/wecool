require 'carrierwave/orm/activerecord'
class Photo < ActiveRecord::Base
  include Twitter::Extractor
  make_voteable
  acts_as_taggable
  belongs_to :persona
  attr_accessible :description, :title, :avatar, :featured, :visible
  mount_uploader :avatar,AvatarUploader
  has_many :mediaset_photos, :dependent => :destroy
  has_many :mediasets, :through => :mediaset_photos
  after_initialize :init

  include Rails.application.routes.url_helpers

  def init(params={})
    self.featured ||= false;
    ActsAsTaggableOn.force_lowercase = true;
  end

  def to_jq_upload 
    { :files => 
      [{
        "name" => self.avatar.to_s.split('/').last, 
        "size" => self.avatar.size,
        "url" => self.avatar.url, 
        "thumbnail_url" => self.avatar.tiny.url,
        "delete_url" => photo_path(self),
        "delete_type" => "DELETE",
        "persona_screen_name" => Persona.find(self.persona_id).screen_name,
        "photo_id" => self.id
      }]
    }
  end
  
  def rotate (degree, version = 'all')
    if version == 'all' then
      @path = self.avatar.path 
    else
      @path = self.avatar.versions[version.to_sym].path
    end

    @photo = Magick::Image.read(@path).first
    @photo.rotate!(degree)

    if version == 'all' then
      @photo.write(self.avatar.path)
      self.avatar.recreate_versions!
    else
      @photo.write(self.avatar.versions[version.to_sym].path)
      #rewrite the original and recreate the rest
      #don't forget to run /script/delayed_job start or else this won't work
      self.delay.rebuild_original_after_transform('rotate', { :degree => degree })
    end
  end
  
  def rebuild_original_after_transform( command, options={})
    @path = self.avatar.path
    @original_photo = Magick::Image.read(self.avatar.path).first
    if command == 'rotate' then
      @original_photo.rotate!(options[:degree])
    end
    @original_photo.write(self.avatar.path)
    self.avatar.recreate_versions! 
  end

  #rebuilt the tag list. useful when you update the title/description 
  # and need to know what's tag that are being used
  def reset_tags
    #check for tags in the title/description
    tags = extract_hashtags self.title
    tags += extract_hashtags self.description
    self.tag_list = tags
    #self.tag_list.add(tags)
    self.save!
  end
    
  #update what photos that this mediaset belongs 
  def update_setlist (newSetlist = Array.new)
    #if !newSetlist.empty? then 
    #  return
    #end

    current_selection = self.mediasets
    new_selection = Mediaset.find(newSetlist)
    if current_selection.empty? && !new_selection.empty? then
      new_selection.each do |mediaset|
        self.mediaset_photos.create(:mediaset_id => mediaset.id, 
          :order => Mediaset.find(mediaset).mediaset_photos.pluck('"order"').max + 1 
        )
      end
    elsif !current_selection.empty? && !new_selection.empty? then
      #add new selection
        new_selection.each do |mediaset|
          if !current_selection.include?(mediaset) then
            self.mediaset_photos.create(
              :mediaset_id => mediaset.id, 
              :order => Mediaset.find(mediaset).mediaset_photos.pluck('"order"').max + 1 
            )
          end
        end

      #delete the ones that are there, but not anymore
      current_selection.each do |mediaset|
        if !new_selection.include?(mediaset) then
          self.mediaset_photos.destroy(self.mediaset_photos.find(
            :all, :conditions => {:mediaset_id => mediaset.id}
          ))
        end
      end
    end
  end

  def self.get_tags ( options = {} )
    default_options = {
      :date_range => 1.day.ago..1.minute.ago, :persona_range => 0..Persona.last.id
    }
   
    if options.has_key? :new_range then
      puts 'new_range=' + options[:new_range]
      if options[:new_range] == '1d' then
        default_options[:date_range] = 1.day.ago..1.minute.ago
      elsif options[:new_range] == '1w' then
        default_options[:date_range] = 1.week.ago..1.minute.ago
      elsif options[:new_range] == '1m' then
        default_options[:date_range] = 1.month.ago..1.minute.ago
      elsif options[:new_range] == 'forever' then
        default_options[:date_range] = 30.years.ago..1.minute.ago
      end
    end

    if options.has_key? :persona then
      default_options[:persona_range] = options[:persona]
    end
    #get recent tags for the last 24 hours, order by tag count
    tags = Photo.joins{ 
      taggings 
    }.group{
      taggings.created_at 
    }.having{ 
      (taggings.created_at.in default_options[:date_range]) & ( persona_id.in default_options[:persona_range] )
    }.tag_counts.order('"count" desc') 


    return tags
  end

  #fetch photos from last_id reference point, options can be modified in the second arguments, otherwise it will
  # defaults to options
  #
  # Options Explaination
  #     FETCH Options
  #     =============
  #     mediatype     => options are photos(default), mediaset, tagset or featured
  #                       photos : fetch photos with :last_id as the reference point
  #                       mediaset: fetch photos in params[:mediaset_id] with params[:last_id] the photo photo
  #                       tagset: fetch photos with params tags params[:tags] with offset [:last_id]
  #                       featured : similiar with photos but fetch photos with featured == true attribute
  #                       related: get related photo of params[:last_id] with offset of params[:offset]
  #                         eg. get related photo of id 28 with offset of 10
  #                       trending : get photos that popular on votes and tags
  #     limit         => limit output to option[:limit] photos
  #     includeFirst  => when fetching photos, include the last_id in the results
  #     author        => limit the photos from options[:author] only
  #     featured      => limit to featured photos only, defaults to any photos 
  #                       [true,false].include? Photo.find(:last_id).featured
  #     excludeMediaset => when fetching photos, exclude photos from certain mediaset
  #     dataRange     => grabs photos from dateRange, must be in firstDate..lastDate format
  #     tag           => grabs photos with certain options[:tag], can only be used with :mediatype = 'tagset'
  #     direction     => to load :limit photos at the end of the :targetDiv ('forward') or
  #                       to load :limit photos at the begining of the :targetDiv ('reverse')
  #
  #     SHOW Options
  #     ============
  #     by default, show options will be processed in '/photos/get_more.js.erb' view
  #       and displayed in this format:-
  #
  #       photos.each do |photo|
  #         <div class="carousel">
  #           photo.avatar.(:size).url
  #           <div class="carousel-indicators"></div>
  #           <div class="carousel-caption"></div>
  #         </div>
  #       end
  #     showCaption   => to load '.carousel-caption' class
  #     draggable     => implement the jquery-ui draggable class
  #     dragSortConnect => specify the jquery-ui sortable class that the draggable element will connect to
  #                     :draggable must be set to something
  #     excludeLinks  => when showing the photo, to allow linkage the photo or '#'
  #     showCaption   => to load '.carousel-caption' class
  #     showIndicators=> to load '.carousel-indicators' class
  #     float         => to implement '.pull-left' class in the carousel
  #     cssDisplay    => how the photos will arranged 
  #     targetDiv     => Where am i going to put these photos
  #     photoCountDiv => Where am i going to update the last/first attribute count in a html container
  #     highlight     => Highlight the photo in :last_id when in photo/featured mode
  # GET /photos/get_more/:last_id(.:format)
  #return next_photos => an array of photos
  def self.get_more( last_id, options={},  
    current_persona={ :signed_in? => false, :current_persona => nil }
  )
    #default options
    default_options = {
      #fetch options
      :mediatype => 'photos', :limit => 10, :includeFirst => false, :author => 0..Persona.last.id, 
      :featured => [true, false], :excludeMediaset => 0,
      :dateRange => 50.years.ago..DateTime.now, :tag => nil, :direction => 'forward',
      :offset => 0, 

      #view options
      :excludeLinks => false, :draggable => false, :dragSortConnect => nil , :enableLinks => true, :size => 'tiny',
      :showCaption => true, :showIndicators => true, :float => true, :cssDisplay => 'inline', 
      :targetDiv => '.endless_scroll_inner_wrap', :photoCountDiv => '.endless-photos', :highlight => false
    }

    #modify options
    if options.has_key? :author then
      default_options[:author] = Persona.find(:first, :conditions => { :screen_name => options[:author]})
    end

    if options.has_key? :excludeMediaset then
      if options[:excludeMediaset].empty? then
        @excluded_mediaset_photos = 0
      else
        @excluded_mediaset_photos = Mediaset.find(options[:excludeMediaset]).photos.pluck(:photo_id)
      end
    else
      @excluded_mediaset_photos = 0
    end

    default_options = default_options.merge(options)

    default_options[:limit] = default_options[:limit].to_i
    if options.has_key? :dateRange then
      @theDate = DateTime.parse options[:dateRange]
      default_options[:dateRange] = @theDate..@theDate+1
    end

    default_options.slice( :includeFirst, :exclueLinks, :draggable, :enableLinks, :showCaption,
      :float, :highlight, :showIndicators).keys.each do |thisKey|
      if default_options[thisKey].is_a? String then
        default_options[thisKey] = default_options[thisKey] == 'true'  
      end
    end

    #process featured 
    if !(default_options[:featured].is_a? Array) then
      default_options[:featured] = default_options[:featured] == 'true'
    else
      default_options[:featured] = [true,false]
    end

    #process featured
    if options[:author].is_a? String then
      default_options[:author] = Persona.find(:first, :conditions => { :screen_name => options[:author] })
    end

    #fetch photos
    if ['photos', 'featured'].include? default_options[:mediatype] then 
      if default_options[:direction] == 'forward' then
        upper = default_options[:includeFirst] ? last_id : last_id - 1
      else
        upper = default_options[:includeFirst] ? last_id : last_id + 1
      end
    else
      if default_options[:direction] == 'forward' then
        upper = default_options[:includeFirst] ? last_id : last_id + 1
      else
        upper = default_options[:includeFirst] ? last_id : last_id - 1
      end
    end

    if default_options[:mediatype] == 'featured' || default_options[:mediatype] == 'photos' then
      persona_range = default_options[:author]
      feature_range = default_options[:featured]
      date_range = default_options[:dateRange]
      thisPersona = current_persona[:signed_in?] ? current_persona[:current_persona].id : 0 
      excluded_sets = @excluded_mediaset_photos
      persona_photos = Photo.where{ persona_id.eq thisPersona }
      other_photos = Photo.where{ (persona_id.not_eq thisPersona ) & (visible.eq true) }
      if default_options[:direction] == 'forward' then 
        @next_photos = Photo.where{
          (id.in(persona_photos.select{id})) | (id.in(other_photos.select{id}))
        }.group(:id).having{
          (id.in 0..upper) & (persona_id.in persona_range) & (featured.in default_options[:featured]) &
          (created_at.in date_range) & (id.not_in excluded_sets)
        }.order('id desc').limit(default_options[:limit])
      else
        #get default_options[:limit] photos before the last_id
        @next_photos = Photo.where{
          (id.in(persona_photos.select{id})) | (id.in(other_photos.select{id}))
        }.group(:id).having{
          (id.in upper..Photo.last.id) & (persona_id.in persona_range) & (featured.in feature_range) &
          (created_at.in date_range) & (id.not_in excluded_sets)
        }.order('id asc').limit(default_options[:limit])
      end
    elsif default_options[:mediatype] == 'tagset' then
      #get latest photos by @opions[:tag]
      persona_range = default_options[:author]
      @next_photos = Photo.tagged_with(
        default_options[:tag]).where{ 
          persona_id.in persona_range 
        }.order('updated_at desc').limit(default_options[:limit]).offset(upper)
    elsif default_options[:mediatype] == 'mediaset' then 
      #if you the owner of the set, you can see all photos, otherwise, only that the ones that you allowed to
      # see
      if current_persona[:signed_in?] && 
        current_persona[:current_persona].id == Mediaset.find(options[:mediaset_id]).persona_id then
        visibility = [true,false]
      else
        visibility = true
      end
      if default_options[:direction] == 'forward' then
        order_range = upper..upper+default_options[:limit]
        @next_photos = Mediaset.joins{ mediaset_photos }.find(options[:mediaset_id]).photos.where{
          mediaset_photos.order.in order_range
        }.order('mediaset_photos."order"').group('mediaset_photos."order"').having(:visible => visibility)
      else
        order_range = (upper-default_options[:limit])..upper
        @next_photos = Mediaset.joins{ mediaset_photos }.find(options[:mediaset_id]).photos.where{
          mediaset_photos.order.in order_range
        }.order('mediaset_photos."order" desc').group('mediaset_photos."order"').having(:visible => visibility)
      end
    elsif default_options[:mediatype] == 'trending' then
      #list down photo based on 
      # a) popular votes
      # b) tag activity
      @next_photos = Photo.joins{ votings }.order("votings.created_at desc").limit(default_options[:limit]).
        offset(last_id).uniq
    elsif default_options[:mediatype] == 'tracked' then
      #get the photos that the current persona tracks
      @tracked_persona = current_persona[:current_persona].followers.where(:tracked_object_type => 'persona')
      @next_photos = Photo.find(:all, :conditions => 
        { :id => 0..upper, :persona_id => @tracked_persona.pluck(:tracked_object_id), :visible=>true} , 
        :order => 'id desc', :limit => default_options[:limit])
    elsif default_options[:mediatype] == 'related' then
      @next_photos = Photo.where( :id => 
        Photo.find(default_options[:focusPhotoID]).find_related_tags.
          limit(default_options[:limit]).offset(last_id).pluck(:'photos.id')
      )
    end

    return { :photos => @next_photos, :options => default_options }
  end
end
