class WelcomeController < ApplicationController
  def index
    #show recent 20
    @photos = Photo.find(:all, :limit=> 20, :order => 'id desc')
    if persona_signed_in? then
      @myPhotos = Photo.find(:all, :limit => 5, :order => 'id desc', 
        :conditions => (:persona_id == current_persona.id))
    end

    respond_to do |format|
      format.html # index.html.erb
      #format.html { render :action => 'show' }
      format.json { render json: @photos }
    end
  end
end
