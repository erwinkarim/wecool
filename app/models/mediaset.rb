class Mediaset < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title
  validates :title, :presence => true
  has_many :mediaset_photos
  has_many :photos, :through => :mediaset_photos
end
