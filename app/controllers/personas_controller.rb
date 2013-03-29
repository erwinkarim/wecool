class PersonasController < ApplicationController
  # GET /personas
  # GET /personas.json
  def index
    @personas = Persona.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @personas }
    end
  end

  # GET /personas/1
  # GET /personas/1.json
  def show
    #@persona = Persona.find(params[:id])
    @persona = Persona.find(:all, :conditions => {:screen_name => params[:id] }).first
    @photos = @persona.photos.find(:all, :order => 'id desc', :conditions => {:featured => true }, :limit => 5)
    if @photos.empty? then 
      @photos = @persona.photos.find(:all, :order => 'id desc', :limit => 5)
    end
    @tracking = Persona.find(:all, :conditions => { :id => @persona.trackers.where(:tracked_object_type => 'persona').pluck(:tracked_object_id)}, :limit => 30)
    @trackers = Persona.find(Tracker.where(:tracked_object_id => @persona.id, :tracked_object_type => 'persona').pluck(:persona_id))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @persona }
    end
  end

  # GET /personas/new
  # GET /personas/new.json
  def new
    @persona = Persona.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @persona }
    end
  end

  # GET /personas/1/edit
  def edit
    #@persona = Persona.find(params[:id])
    @persona = Persona.find(:all, :conditions => {:screen_name => params[:id] }).first
  end

  # POST /personas
  # POST /personas.json
  def create
    @persona = Persona.new(params[:persona])

    respond_to do |format|
      if @persona.save
        format.html { redirect_to @persona, notice: 'Persona was successfully created.' }
        format.json { render json: @persona, status: :created, location: @persona }
      else
        format.html { render action: "new" }
        format.json { render json: @persona.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /personas/1
  # PUT /personas/1.json
  def update
    @persona = Persona.find(params[:id])
    #@persona = Persona.find(:all, :conditions => {:screen_name => params[:id] }).first

    respond_to do |format|
      if @persona.update_attributes(params[:persona])
        format.html { redirect_to persona_path(@persona.screen_name), notice: 'Persona was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @persona.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personas/1
  # DELETE /personas/1.json
  def destroy
    @persona = Persona.find(params[:id])
    @persona.destroy

    respond_to do |format|
      format.html { redirect_to personas_url }
      format.json { head :no_content }
    end
  end

  # GET   /personas/:persona_id/picture
  def get_picture
    if persona_signed_in? then
      @persona = current_persona

      respond_to do |format| 
        format.html
      end
    else
    end
  end

  # POST   /personas/:persona_id/picture
  # supplies varabiles:--
  #   x_coor, y_coor, h_coor, w_coor : dimensions 
  #   selected_photo_path : where to load the photo
  def set_picture
    #load new picture
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] } )
    @persona.avatar = File.open(Rails.root.to_s + '/public' + params[:selected_photo_path])
    @persona.save!

    #crop picture
    @persona.crop params[:x_coor].to_i, params[:y_coor].to_i, params[:h_coor].to_i, params[:w_coor].to_i

    respond_to do |format|
      format.html { redirect_to persona_path(@persona.screen_name), notice: 'Persona Picture Updated' } 
    end
  end

  # GET    /personas/get_more/:last_id
  # get more persona listings, in desending order with upper bound is last_id
  # options:-
  #     fetch_mode => normal, trackers or tracking
  #       normal: get normal listing
  #       trackers: get the trackers of Persona(fetch_focus_id)
  #       tracking: get persona that Persona(fetch_focus_id) is tracking
  def get_more
    @options = {
      :includeFirst => false, :limit => 10, :fetch_mode => 'normal', :fetch_focus_id => 0  
    }

    if params.has_key? :includeFirst then
      @options[:includeFirst] = params[:includeFirst] == 'true' ? true : false 
    end

    upper = @options[:includeFirst] ? 0..params[:last_id].to_i : 0..(params[:last_id].to_i - 1)

    if @options[:fetch_mode] == 'normal' then
      @next_personas = Persona.where( :id => upper).order('id desc').limit(@options[:limit])
    end
  end
end
