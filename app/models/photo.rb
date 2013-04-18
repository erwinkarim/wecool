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
end
