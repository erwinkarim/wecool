class Tracker < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :object_id, :object_type, :relationship
end
