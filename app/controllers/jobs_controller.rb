class JobsController < ApplicationController
  
  #GET    /personas/:persona_id/jobs(.:format)
  #show last 10 pending jobs by params[:persona_id]
  def index
    #clean up old jobs
    

    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @persona.jobs.where(
      :job_id => @persona.jobs.map{ |x| x.job_id } - 
        Delayed::Job.where(:id => @persona.jobs.map{ |x| x.job_id } ).pluck(:id)
    ).each{ |x| x.destroy }
    @jobs = Delayed::Job.where( :id => @persona.jobs.map{ |x| x.job_id }).order(:id).reverse[0..9]
		@last_id = @jobs.empty? ? 0 : @jobs.first.id
  end

  #GET    /personas/:persona_id/jobs/get_more
  #get olders jobs from :job-id
  def get_more
    @persona = Persona.where(:screen_name => params[:persona_id]).first
		if params.has_key? :'job-id' then
      current_job_id = params[:'job-id']
			@jobs = Delayed::Job.where( :id => 
				@persona.jobs.where{ job_id.lt current_job_id }.map{ |x| x.job_id }
			).reverse[0..9]
		else
			@jobs = Delayed::Job.where( :id => @persona.jobs.map{ |x| x.job_id }).order(:id).reverse[0..9]
		end

    respond_to do |format|
      format.html
      format.json { 
        render :json => @jobs.map{ 
          |x| { 
            :id => x.id, :type => YAML::load(x.handler).object.to_s,  
            :url => ApplicationHelper::generate_obj_url(YAML::load(x.handler).object),  
            :method_name => YAML::load(x.handler).method_name, :started => x.run_at ,
            :attempts => x.attempts
          }
        }
      }
      format.js
    end
  end
  
end
