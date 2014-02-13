module ApplicationHelper
  include ActionView::Helpers::UrlHelper
	include Twitter::Autolink

	def self.generate_obj_url object
		if object.instance_of? Photo then
			return Rails.application.routes.url_helpers.photo_view_path(Persona.find(object.persona_id).screen_name, object.id) 
			return Rails.application.routes.url_helpers.persona_path(Persona.where(:screen_name => object.screen_name).first) 
		else
			return nil
		end
	end
end
