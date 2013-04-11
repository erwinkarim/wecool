require 'carrierwave/orm/activerecord'
class Photo < ActiveRecord::Base
  make_voteable
  belongs_to :persona
  attr_accessible :description, :title, :avatar, :featured, :visible
  mount_uploader :avatar,AvatarUploader
  has_many :mediaset_photos, :dependent => :destroy
  has_many :mediasets, :through => :mediaset_photos
  after_initialize :init

  include Rails.application.routes.url_helpers

  def init(params={})
    self.featured ||= false;
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
end
