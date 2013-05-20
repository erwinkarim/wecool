class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_for_paper_trail
    persona_signed_in? ? current_persona.screen_name : nil
  end
end
