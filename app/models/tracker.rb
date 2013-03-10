class Tracker < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :relationship, :tracked_object_id, :tracked_object_type
  validates :relationship, :presence => true
  validates :tracked_object_id, :presence => true
  validates :tracked_object_type, :presence => true
  validates_uniqueness_of :tracked_object_id, :scope => [:tracked_object_type, :persona_id]
end
