class Mediaset < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :description, :title
end
