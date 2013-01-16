require 'carrierwave/orm/activerecord'
class Photo < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title, :avatar
  mount_uploader :avatar,AvatarUploader
end
