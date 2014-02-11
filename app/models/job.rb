class Job < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :job_id
end
