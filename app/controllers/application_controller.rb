class ApplicationController < ActionController::Base
  protect_from_forgery
	layout :determine_layout

  def user_for_paper_trail
    persona_signed_in? ? current_persona.screen_name : nil
  end

	def check_for_mobile
		session[:mobile_override] = params[:mobile] if params[:mobile]
		prepare_for_mobile if mobile_device?
	end

	def prepare_for_mobile
		prepend_view_path Rails.root + 'app' + 'views_mobile'
	end

	def mobile_device?
		if session[:mobile_override]
			session[:mobile_override] == "1"
		else
			# Season this regexp to taste. I prefer to treat iPad as non-mobile.
			(request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
		end
	end

	helper_method :mobile_device?

	def determine_layout
		if mobile_device? then
			"mobile"
		else
			"application"
		end
	end
end
