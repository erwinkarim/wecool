class Job < ActiveRecord::Base
  belongs_to :persona
  attr_accessible :job_id
	
	def self.cleanup
		#find Jobs not in Delayed::Job then delete them
		self.where(:job_id => 
			Delayed::Job.pluck(:id) - self.all.map{|x| x.job_id }
		).each{ |x| x.destory} 
	end
end
