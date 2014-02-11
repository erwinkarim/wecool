class JobsController < ApplicationController
  
  #GET    /personas/:persona_id/jobs(.:format)
  #show pending jobs by params[:persona_id]
  def index
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @jobs = Delayed::Job.where( :id => @persona.jobs.map{ |x| x.job_id })
  end
end
