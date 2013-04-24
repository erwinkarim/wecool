class PhotosController < ApplicationController
  #include Twitter::Extractor
  before_filter :check_if_allowed_to_view, :only => [:view]

  def check_if_allowed_to_view
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @photo = @persona.photos.find(params[:id])
    if !@photo.visible && current_persona != @persona then
      respond_to do |format|
        format.html { render :text => 'Photo is not viewable by you', :layout => true }
      end
    end
  end

  # GET /photos
  # GET /photos.json
  def index
    #show recent 40
    @photos = Photo.find(:all, :limit=> 35, :order => 'id desc')

    respond_to do |format|
      format.html # index.html.erb
      #format.html { render :action => 'show' }
      format.json { render json: @photos }
    end
  end

  # GET /photos/:persona_id
  # GET /photos/:persona_id.json
 def show
    #show photos uploaded by persona
    if params[:id] == 'everyone' then
      @persona = Persona.new(:screen_name => 'everyone')
    else
      @persona = Persona.find(:all, :conditions => { :screen_name => params[:id]}, :limit => 1 ).first
    end

    if params.has_key? :view_mode then
      
    end

    @last_photo = @persona.photos.empty? ? Photo.new : @persona.photos.last

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @persona.photos }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = current_persona.photos.new(params[:photo])
    @persona = current_persona
    #@photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = current_persona.photos.new(params[:photo])
    @photo.title = @photo.avatar.to_s.split('/').last

    respond_to do |format|
      if @photo.save
        @photo.reset_tags
        #add the mediasets
        if !params["mediaset"].empty? then
          @photo.update_setlist params[:mediaset]
        end

        format.html {
          render :json => [@photo.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => @photo.to_jq_upload.to_json, status: :created, location: @photo
        }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    #todo
    # Ensure that updates is allowed by the owner
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        @photo.reset_tags
        format.html { redirect_to photo_view_path(Persona.find(@photo.persona_id).screen_name, @photo.id), 
          notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    #todo
    # Ensure that updates is allowed by the owner
    
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end
  
  # GET    /photos/:photo_id/upload
  def upload
  end
 
  # VERB /photos/:persona_id/versions/:photo_id  
  def version
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @photo = @persona.photos.find(params[:photo_id])

    @avatar = nil
    if params.has_key? :size then
      if params[:size] == 'original' then
        @avatar = @photo.avatar
      else
        @avatar = @photo.avatar.versions[params[:size].to_sym]
      end
    else
      @avatar = @photo.avatar.xlarge  
      params[:size] = 'xlarge'
    end
  end

  # GET    /photos/:persona_id/editor/:photo_id(.:format) 
  def editor
    @photo = Photo.find(params[:photo_id])
    @persona = Persona.find(@photo.persona_id)
  end

  #  GET    /photos/:persona_id/view/:id(.:format)
  def view
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id] }).first
    @photo = @persona.photos.find(params[:id])
    @related_photos = @photo.find_related_tags.limit(8)

    @total_votes = @photo.up_votes + @photo.down_votes
    @mediasets = @persona.mediasets

    # setup links to prev/next photos
    if params[:scope] == 'mediaset' then
      @current_mediaset = Mediaset.find(params[:scope_id])
      current_pos = @current_mediaset.mediaset_photos.where(:photo_id => params[:id]).first.order
      @prev_photo = Mediaset.joins{ mediaset_photos }.find(params[:scope_id]).photos.
        where{ mediaset_photos.order.lt current_pos }.order('"order"').last
      @next_photo = Mediaset.joins{ mediaset_photos }.find(params[:scope_id]).photos.
        where{ mediaset_photos.order.gt current_pos }.order('"order"').first
      @prev_photo_path = @prev_photo.nil? ? '#' : 
        photo_view_in_scope_path(@persona.screen_name, @prev_photo, 'mediaset', @current_mediaset) + 
        '#photo'
      @next_photo_path = @next_photo.nil? ? '#' : 
        photo_view_in_scope_path(@persona.screen_name, @next_photo, 'mediaset', @current_mediaset) + 
        '#photo'
    elsif params[:scope] == 'featured' then
      photoID = @photo.id
      @prev_photo = @persona.photos.where{ (id.gt photoID) & (featured.eq true) }.first
      @next_photo = @persona.photos.where{ (id.lt photoID) & (featured.eq true) }.order('id desc').first
      @prev_photo_path = @prev_photo.nil? ? '#' : 
        photo_view_in_scope_path(@persona.screen_name, @prev_photo, 'featured', 0) + '#photo'
      @next_photo_path = @next_photo.nil? ? '#' : 
        photo_view_in_scope_path(@persona.screen_name, @next_photo, 'featured', 0) + '#photo'
    else
      #normal scope, view photo scope
      photoID = @photo.id
      visibleScope = current_persona == @persona ? [true,false] : [true]
      @prev_photo = @persona.photos.where{ 
        (id.gt photoID) & (visible.in visibleScope) }.first
      @next_photo = @persona.photos.where{
        (id.lt photoID) & (visible.in visibleScope) 
      }.order('id desc').first
      @prev_photo_path = @prev_photo.nil? ? '#' : photo_view_path(@persona.screen_name, @prev_photo) + '#photo'
      @next_photo_path = @next_photo.nil? ? '#' : photo_view_path(@persona.screen_name, @next_photo) + '#photo'
    end

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @photo.to_jq_upload.to_json, status: :created, location: @photo }
    end
  end

  # GET /photos/:persona_id/view/:id/exif(.:format)
  def view_exif
    #view exif data of this photo
    @photo = Photo.find(params[:id])
    @persona = Persona.find(@photo.persona_id)
    @exif = EXIFR::JPEG.new(@photo.avatar.path).exif

    respond_to do |format|
      format.html # view_exif.html.erb
      format.json { render json: @photo }
    end
  end

  # POST   /photos/:persona_id/update_setlist/:photo_id(.:format)
  def update_setlist
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id]}).first
    @photo = @persona.photos.find(params[:photo_id])

    @photo.update_setlist params[:mediaset]
    respond_to do |format|
      format.html { redirect_to :back, :notice => 'Mediaset Selection Updated' }
    end
  end

  # todo: get more on trendiness and the ones that you tracked
  # Options Explaination
  #     FETCH Options
  #     =============
  #     mediatype     => options are photos(default), mediaset, tagset or featured
  #                       photos : fetch photos with :last_id as the reference point
  #                       mediaset: fetch photos in params[:mediaset_id] with params[:last_id] the photo photo
  #                       tagset: fetch photos with params tags params[:tags] with offset [:last_id]
  #                       featured : similiar with photos but fetch photos with featured == true attribute
  #     direction     => to load :limit photos at the end of the :targetDiv ('forward') or
  #                       to load :limit photos at the begining of the :targetDiv ('reverse')
  #
  #     SHOW Options
  #     ============
  #     showCaption   => to load '.carousel-caption' class
  #     showIndicators=> to load '.carousel-indicators' class
  #     targetDiv     => Where am i going to put these photos
  #     photoCountDiv => Where am i going to update the last/first attribute count in a html container
  #     highlight     => Highlight the photo in :last_id when in photo/featured mode
  # GET /photos/get_more/:last_id(.:format)
  def get_more

    current_options = params.inject({}){ |memo, (k,v)| memo[k.to_sym] = v; memo }
    if !['trending', 'tracked'].include? params[:mediatype] then
      if params[:mediatype] != 'mediaset' then
        @current_photo = Photo.find(params[:last_id])
      else
        @current_photo = Photo.find(
          MediasetPhoto.where(:mediaset_id => params[:mediaset_id]).where( :order => params[:last_id]).pluck(:photo_id).first
        )
      end
    end
    results = Photo.get_more( 
      params[:last_id].to_i, 
      current_options, 
      { :signed_in? => persona_signed_in? , :current_persona => current_persona }
    )

    @options = results[:options]
    @next_photos = results[:photos]
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET    /photos/:persona_id/get_single/:photo_id(.:format) 
  def get_single
    @options = {
        #view options
        :size => 'tiny',
    }

    if params.has_key? :size then
      @options[:size] = params[:size]
    end
    @persona = Persona.find(:first, :conditions => {:screen_name => params[:persona_id]})
    @photo = @persona.photos.find(params[:photo_id])
    @photo_path = @photo.avatar.send(@options[:size])

    respond_to do |format|
      format.js
      format.html
    end
  end

  #  POST   /photos/:persona_id/toggle_featured/:photo_id
  def toggle_featured
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @photo = @persona.photos.find(params[:photo_id])
    @photo.toggle(:featured)
    @photo.visible = true

    if @photo.save then
      render :status => :ok
    else
      render :status => :internal_server_error
    end
  end

  # POST   /photos/vote/:photo_id/:vote_mode/by/:persona_id(.:format)
  def vote
    @photo = Photo.find(params[:photo_id]) 
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id]})

    if params[:vote_mode] == 'up' then
      @persona.up_vote(@photo)
    elsif params[:vote_mode] == 'down' then
      @persona.down_vote(@photo)
    end

    respond_to do |format|
      format.js
    end
  end

  # POST   /photos/unvote/:photo_id/by/:persona_id(.:format)
  def  unvote
    @photo = Photo.find(params[:photo_id])
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id]})

    @persona.unvote(@photo)

    respond_to do |format|
      format.js
    end
  end

  #  POST /photos/:persona_id/transform/:photo_id/:method?arg1=val1&arg2=val2....argn=valn
  def transform
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    @photo = @persona.photos.find(params[:photo_id])

    if persona_signed_in? && current_persona.screen_name == params[:persona_id] then
      if params.has_key? :current_version then
        version = params[:current_version]
      else
        version = 'all'
      end
      if params[:method] == 'rotate' then
        #rotate the picture
        if params[:direction] == 'left' then
          @photo.rotate(-90, version)
        elsif params[:direction] == 'right' then
          @photo.rotate(90, version)
        end
      end    
    end
  
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST   /photos/:persona_id/download/:id(
  # download pictures 
  def download
    @photo = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] }).photos.find(params[:id])
    if @photo.nil? then
      respond_to do |format|
        format.html { redirect_to :back, :notice => 'photo not found' }
      end
    else
      if params.has_key? :size then
        if params[:size] == 'original' then
          @avatar = @photo.avatar
        else
          @avatar = @photo.avatar.versions[params[:size].to_sym]
        end
      else
        @avatar = @photo.avatar.xlarge
      end
    
      send_file @avatar.path
    end
    
  end

  # POST   /photos/:persona_id/toggle_visibility/:photo_id
  def toggle_visibility
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })  
    @photo = @persona.photos.find(params[:photo_id])

    @photo.toggle(:visible)
    if @photo.save then
      render :status => :ok
    else
      render :status => :internal_server_error
    end
  end
end
