class MediasetsController < ApplicationController
  # GET /mediasets
  # GET /mediasets.json
  def index
    @mediasets = Mediaset.find(:all, :limit =>10, :order => 'id desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mediasets }
      format.js 
    end
  end

  # GET /mediasets/persona_id
  # GET /mediasets/persona_id.json
  def show
    #@mediaset = Mediaset.find(params[:id])
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:id] }).first
    @default_photos = @persona.photos.find(:all, :order => 'id desc', :limit => 10)
    @mediasets = @persona.mediasets.find(:all, :order => 'id desc')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mediaset }
    end
  end

  # GET /mediasets/new
  # GET /mediasets/new.json
  def new
    #@mediaset = Mediaset.new
    if persona_signed_in? then
      @mediaset = current_persona.mediasets.new
      @persona = current_persona
    end
    @mediaset_photos = Array.new
    #@photos = Photo.find(:all, :order => 'id desc',  :conditions => {
    #  :persona_id => Persona.find(:first, :conditions => {:screen_name => current_persona.screen_name} )
    #})

    @upload_date_list = Photo.where(:persona_id => @persona.id).pluck(:created_at).map{|s| s.to_date }.uniq.reverse

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mediaset }
    end
  end

  # GET /mediasets/1/edit
  # GET /mediasets/:persona_id/edit/:id(.:format)
  def edit
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @mediaset = Mediaset.find(params[:id])
    @mediaset_photos = @mediaset.photos
    @photos = Photo.find(:all, :order => 'id desc',  :conditions => {
      :persona_id => Persona.find(:first, :conditions => {:screen_name => params[:persona_id]} )
    })
    @upload_date_list = Photo.where(:persona_id => @persona.id).pluck(:created_at).map{|s| s.to_date }.uniq.reverse
  end

  # POST /mediasets
  # POST /mediasets.json
  def create
    #@mediaset = Mediaset.new(params[:mediaset])
    if persona_signed_in? then
      @mediaset = current_persona.mediasets.new(params[:mediaset])
      if !params.has_key? :photo then
        @new_selection = Array.new
        @new_selection.push Photo.new
      else
        @new_selection = Photo.find(params[:photo])
      end
    end

    respond_to do |format|
      if @mediaset.save
        #add the photos
        if !@new_selection.empty? then
          @new_selection.each do |photo|
            @mediaset.mediaset_photos.create(:photo_id => photo.id)
          end 
        end 
        
        format.html { redirect_to view_sets_path(current_persona.screen_name, @mediaset),
          notice: 'Mediaset was successfully created.' }
        #format.html { redirect_to :back,notice: 'Mediaset was successfully created.' }
        format.json { render json: @mediaset, status: :created, location: @mediaset }
        format.js 
      else
        format.html { render action: "new" }
        format.json { render json: @mediaset.errors, status: :unprocessable_entity }
        format.js 
      end
    end
  end

  # PUT /mediasets/1
  # PUT /mediasets/1.json
  # params[:photo[]] holds photolist in order
  def update
    @persona = current_persona
    @upload_date_list = Photo.where(:persona_id => @persona.id).pluck(:created_at).map{|s| s.to_date }.uniq.reverse
    @mediaset = Mediaset.find(params[:id])
    @current_selection = @mediaset.photos

    current_order = 1
    if @current_selection.empty? then
      #empty mediaset, create new ones
      params[:photo].each do |photo|
        @mediaset.mediaset_photos.create(:photo_id => photo, :order => current_order)
        current_order += 1
      end
    else
      #reset ordering
      @mediaset.mediaset_photos.update_all('"order" = 0')

      #reset ordering, add new entries if not found in current list
      params[:photo].each do |photo_id|
        @current_photo = @mediaset.mediaset_photos.where(:photo_id => photo_id)
        if @current_photo.empty? then
          @mediaset.mediaset_photos.create(:photo_id => photo_id, :order => current_order)
        else
          @current_photo.first.update_attribute(:order, current_order)
        end
        current_order += 1
      end 
      @mediaset.mediaset_photos.where(:order => 0).delete_all
    end

    respond_to do |format|
      if @mediaset.update_attributes(params[:mediaset])
        format.html { 
          redirect_to view_sets_path(current_persona.screen_name, 
            @mediaset), notice: 'Mediaset was successfully updated'
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mediaset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mediasets/1
  # DELETE /mediasets/1.json
  def destroy
    @mediaset = Mediaset.find(params[:id])
    @mediaset.destroy

    respond_to do |format|
      format.html { redirect_to mediasets_url }
      format.json { head :no_content }
    end
  end

  #  GET    /mediasets/:persona_id/view/:id(.:format)
  def view
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id] }).first
    @mediaset = @persona.mediasets.find(params[:id])
    @mediaset_photos = @mediaset.photos.empty? ? Photo.all.reverse : @mediaset.photos.find(:all, :order => 'id desc', :limit=>10)
    @total_votes = @mediaset.up_votes + @mediaset.down_votes
  end

  # POST   /mediasets/vote/:mediaset_id/:vote_mode/by/:persona_id
  def vote
    @mediaset = Mediaset.find(params[:mediaset_id])
    @persona = Persona.find(:first, :conditions => {:screen_name => params[:persona_id]})

    if params[:vote_mode] == 'up' then
      @persona.up_vote(@mediaset)
    elsif params[:vote_mode] == 'down' then
      @persona.down_vote(@mediaset)
    end
  
    @total_votes = @mediaset.up_votes +  @mediaset.down_votes

    respond_to do |format|
      format.js
    end
  end
 
  #  POST   /mediasets/unvote/:mediaset_id/by/:persona_id
  def unvote
    @mediaset = Mediaset.find(params[:mediaset_id])
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id]})


    if @persona.unvote(@mediaset) then
      @total_votes = @mediaset.up_votes +  @mediaset.down_votes
      render :status => :ok
    else
      render :status => :internal_server_error
    end

  end

  # POST   /mediasets/toggle_featured/:mediaset_id
  def toggle_featured
    @mediaset = Mediaset.find(params[:mediaset_id])
    @mediaset.toggle(:featured)
    if @mediaset.save then
      render :status => :ok
    else
      render :status => :internal_server_error
    end
  end

  # get more mediasets from last_id
  # GET    /mediasets/get_more/:last_id
  def get_more
    @options = { :includeFirst => false , :limit => 5, :persona => 0..Persona.last.id , 
      :featured => [true,false], :viewType => 'normal' }
    
    @options[:includeFirst] = params[:includeFirst] == 'true' ? true : false 

    if params.has_key? :persona then
      @options[:persona] = params[:persona].to_i
    end

    if params.has_key? :limit then
      @options[:limit] = params[:limit].to_i
    end

    if params.has_key? :featured then
      if params[:featured] == 'true' then
        @options[:featured] = true
      elsif params[:featured] == 'false' then
        @options[:featured] = false
      end
    end

    if params.has_key? :viewType then
      if params[:viewType] == 'tracked' then
        @options[:viewType] = params[:viewType]
        @tracked_persona = current_persona.trackers.where(:tracked_object_type => 'persona')
      end
    end

    upper = @options[:includeFirst] ? params[:last_id].to_i : params[:last_id].to_i - 1
    if @options[:viewType] == 'normal' then 
      @next_mediasets = Mediaset.find(:all, :conditions => { 
        :id => 0..upper, :persona_id => @options[:persona], :featured => @options[:featured]  }, 
        :limit => @options[:limit], :order => 'id desc' )
    elsif @options[:viewType] == 'tracked' then
      @next_mediasets = Mediaset.find(:all, :conditions => { 
        :id => 0..upper, :persona_id => @tracked_persona.pluck(:tracked_object_id), 
        :featured => @options[:featured]  }, 
        :limit => @options[:limit], :order => 'id desc' )
    end

    respond_to do |format|
      format.js
      format.html
    end
  end
end
