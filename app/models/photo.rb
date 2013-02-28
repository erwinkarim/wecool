require 'carrierwave/orm/activerecord'
class Photo < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title, :avatar, :featured
  mount_uploader :avatar,AvatarUploader
  has_many :mediaset_photos, :dependent => :destroy
  has_many :mediasets, :through => :mediaset_photos
  after_initialize :init

  include Rails.application.routes.url_helpers

  def init
    self.featured ||= false;
  end
  def to_jq_upload 
    {
      "name" => self.avatar.to_s.split('/').last, 
      "size" => self.avatar.size,
      "url" => self.avatar.url, 
      "thumbnail_url" => self.avatar.tiny.url,
      "delete_url" => photo_path(self),
      "delete_type" => "DELETE",
      "persona_screen_name" => Persona.find(self.persona_id).screen_name,
      "photo_id" => self.id
    }
  end

end
