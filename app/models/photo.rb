require 'carrierwave/orm/activerecord'
class Photo < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title, :avatar
  mount_uploader :avatar,AvatarUploader

  include Rails.application.routes.url_helpers

  def to_jq_upload 
    {
      "name" => self.avatar.to_s.split('/').last, 
      "size" => self.avatar.size,
      "url" => self.avatar, 
      "delete_url" => photo_path(self),
      "delete_type" => "DELETE" 
    }
  end
end
