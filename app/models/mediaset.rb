class Mediaset < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title
  validates :title, :presence => true
end
