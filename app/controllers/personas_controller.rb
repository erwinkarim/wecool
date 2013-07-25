class PersonasController < ApplicationController
  before_filter :require_login, :only => :upgrade_acc

  def require_login
    unless persona_signed_in?
      flash[:error] = 'You must sign in first'
      redirect_to new_persona_session_path
    end
  end

  # GET /personas
  # GET /personas.json
  def index
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
    @following = Persona.find(:all, :conditions => { :id => @persona.followers.where(:tracked_object_type => 'persona').pluck(:tracked_object_id)}, :limit => 30)
    @followers = Persona.find(Follower.where(:tracked_object_id => @persona.id, :tracked_object_type => 'persona').pluck(:persona_id))

    if persona_signed_in? && @persona == current_persona && !@persona.premium? then
      @bandwidth = current_persona.photos.where{ created_at.gt Date.today.at_beginning_of_month }.map{ |p| p.avatar.size }.sum 
      @exceed_bandwidth = @bandwidth > 300*1024*1024 
    end

    # gather 1 month activity by cluster of 15 minutes
    @activity = @persona.get_activity

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
  #     fetch_mode => normal, follower or following
  #       normal: get normal listing
  #       followers: get the followers of Persona(fetch_focus_id)
  #       following: get persona that Persona(fetch_focus_id) is following
  def get_more
    @options = {
      :includeFirst => false, :limit => 10, :fetch_mode => 'normal', :fetch_focus_id => 0,
      :handle => ".endless_scroll_inner_wrap"  
    }

    if params.has_key? :includeFirst then
      @options[:includeFirst] = params[:includeFirst] == 'true' ? true : false 
    end

    if params.has_key? :fetch_mode then
      if params[:fetch_mode] == 'following' then
        @options[:fetch_mode] = 'following'
      elsif params[:fetch_mode] == 'followers' then
        @options[:fetch_mode] = 'followers'
      end
    end

    if params.has_key? :fetch_focus_id then
      @options[:fetch_focus_id] = params[:fetch_focus_id].to_i
    end

    if params.has_key? :handle then
      @options[:handle] = params[:handle]
    end

    upper = @options[:includeFirst] ? 0..params[:last_id].to_i : 0..(params[:last_id].to_i - 1)

    if @options[:fetch_mode] == 'normal' then
      @next_personas = Persona.where( :id => upper).order('id desc').limit(@options[:limit])
    elsif @options[:fetch_mode] == 'following' then
      persona = Persona.find(@options[:fetch_focus_id])
      @next_personas = Persona.where(
          :id => persona.followers.where(:tracked_object_type => 'persona', 
          :tracked_object_id => upper ).pluck(:tracked_object_id) 
        ).order('id desc').limit(@options[:limit])
    elsif @options[:fetch_mode] == 'followers' then
      persona = Persona.find(@options[:fetch_focus_id])
      @next_personas = Persona.where(:id => Follower.where(
        :tracked_object_id => persona.id, :tracked_object_type => 'persona').pluck(:persona_id)
      ).order('id desc').group(:id).having(:id => upper)
    end
  end

  #GET    /personas/:persona_id/tags(.:format) 
  def tags
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @tags = Photo.get_tags( { :persona => @persona.id } )

    respond_to do |format|
      format.html { render "tags/index", :locals => {:tags => @tags, :persona => @persona }  }
    end
  end

  #GET    /personas/:persona_id/tags/:tag_id(.:format) 
  # show photos from :persona_id that has :tag_id
  def show_tag
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @tag = params[:tag_id]

		js :params => { :persona => @persona.screen_name, :tag => @tag } 

    respond_to do |format|
      format.html{ render "tags/show", :locals => {:tag => @tag, :persona => @persona } }
    end
  end

  # GET /personas/:persona_id/upgrade_to_premium(.:format)
  def upgrade_acc
    @persona = Persona.where(:screen_name => params[:persona_id]).first

    respond_to do |format|
      format.html
    end
  end
end
