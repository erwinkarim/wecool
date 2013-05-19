class Mediaset < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title, :system_visible
  validates :title, :presence => true
  has_many :mediaset_photos, :dependent => :destroy
  has_many :photos, :through => :mediaset_photos
  make_voteable
  has_paper_trail
end
