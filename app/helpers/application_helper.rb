module ApplicationHelper
	include Twitter::Autolink

	def generate_obj_link object
		if object.instance_of? Photo then
			return link_to( 'Photo', photo_view_path(Persona.find(object.persona_id).screen_name, object.id))
		elsif object.instance_of? Persona then
			return link_to('Persona', persona_path(Persona.where(:screen_name => object.screen_name).first) )
		else
			return object
		end
	end
end
