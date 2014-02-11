class JobsController < ApplicationController
  
  #GET    /personas/:persona_id/jobs(.:format)
  #show last 10 pending jobs by params[:persona_id]
  def index
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @jobs = Delayed::Job.where( :id => @persona.jobs.reverse[0..9].map{ |x| x.job_id }).reverse
  end

  #GET    /personas/:persona_id/jobs/:job_id/get_more
  #get olders jobs from :job_id
  def get_more
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @jobs = Delayed::Job.where( :id => @persona.jobs.where{ job_id.lt params[:job_id] }.reverse[0..9].map{ 
      |x| x.job_id }
    ).reverse
  end
  
end
