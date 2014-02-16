class JobsController < ApplicationController
  
  #GET    /personas/:persona_id/jobs(.:format)
  #show last 10 pending jobs by params[:persona_id]
  def index
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @jobs = Delayed::Job.where( :id => @persona.jobs.reverse[0..9].map{ |x| x.job_id })
		@last_id = Delayed::Job.last.id + 1
  end

  #GET    /personas/:persona_id/jobs/get_more
  #get olders jobs from :job_id
  def get_more
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    current_job_id = params[:job_id]
		if params.has_key? :job_id then
			@jobs = Delayed::Job.where( :id => 
				@persona.jobs.where{ job_id.lt current_job_id }.reverse[0..9].map{ |x| x.job_id }
			).reverse
		else
			@jobs = Delayed::Job.where( :id => @persona.jobs.reverse[0..9].map{ |x| x.job_id })
		end

    respond_to do |format|
      format.html
      format.json { 
        render :json => @jobs.map{ 
          |x| { 
            :id => x.id, :type => YAML::load(x.handler).object.to_s,  
            :url => ApplicationHelper::generate_obj_url(YAML::load(x.handler).object),  
            :method_name => YAML::load(x.handler).method_name, :started => x.run_at 
          }
        }
      }
      format.js
    end
  end
  
end
