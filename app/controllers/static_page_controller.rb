class StaticPageController < ApplicationController
  caches_page :tour

  def tour
  end
  
  def aboutUs
  end

  def termsAndConditions
  end

  def browser_unsupported 
    render :layout => 'test'
  end

	def about_wecool
	end
	
	def organize_photo
	end

	def online_editing
	end

	#  POST   /static/feedback(.:format) 
	#get feedback data, post an email to feedback@sirap.co
	def feedback
    if !params['comment'].empty? then
      #collect feedback and send it out to email.
      #also if, the guy is logged in, send out confirmation on the feedback
      options = { :comment => params['comment'], :url => params['url'] } 
      if persona_signed_in? then
        options[:from] = current_persona.email
        options[:screen_name] = current_persona.screen_name
      end
      AppMailer.feedback(options).deliver
    end
	end

end
