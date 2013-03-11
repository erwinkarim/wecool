class PhotosController < ApplicationController
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

    @last_photo = @persona.photos.last

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = current_persona.photos.new(params[:photo])
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
        #format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        #format.html { redirect_to photo_view_path(current_persona, @photo.id) , notice: 'Photo was successfully created.' }
        #format.json { render json: @photo, status: :created, location: @photo }
        format.html {
          render :json => [@photo.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: [@photo.to_jq_upload].to_json }
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
        format.html { redirect_to photo_view_path(Persona.find(@photo.persona_id).screen_name, @photo.id), notice: 'Photo was successfully updated.' }
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
  
  def upload
  end
 
  # VERB /photos/:persona_id/versions/:photo_id  
  def version
    @photo = Photo.find(params[:photo_id])

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

  def editor
    @photo = Photo.find(params[:photo_id])
    @persona = Persona.find(@photo.persona_id)
  end

  def view
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id] }).first
    @photo = @persona.photos.find(params[:id])
    @total_votes = @photo.up_votes + @photo.down_votes
    @mediasets = @persona.mediasets

    @prev_photo = @persona.photos.find(:first, :conditions => 'id >'+@photo.id.to_s)
    @next_photo = @persona.photos.find(:first, :conditions => 'id <'+@photo.id.to_s, :order=>'id desc')

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @photo }
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
    @current_selection = @photo.mediasets
    @new_selection = Mediaset.find(params[:mediaset])

    if @current_selection.empty? && !@new_selection.empty? then
      @new_selection.each do |mediaset|
        @photo.mediaset_photos.create(:mediaset_id => mediaset.id)
      end
    elsif !@current_selection.empty? && !@new_selection.empty? then
      #add new selection
        @new_selection.each do |mediaset|
          if !@current_selection.include?(mediaset) then
            @photo.mediaset_photos.create(:mediaset_id => mediaset.id)
          end
        end

      #delete the ones that are there, but not anymore
      @current_selection.each do |mediaset|
        if !@new_selection.include?(mediaset) then
          @photo.mediaset_photos.destroy(@photo.mediaset_photos.find(:all, :conditions => {:mediaset_id => mediaset.id}))
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to :back, :notice => 'Mediaset Selection Updated' }
    end
  end

  # GET /photos/get_more/:last_id(.:format)
  # todo: get more on trendiness and the ones that you tracked
  def get_more
   
    @options = {
      :mediatype => 'photos', :size => 'tiny',
      :limit => 10, :inculdeFirst => false, :author => 0..Persona.last.id, 
      :featured => [true, false]
    }

    if params.has_key? :mediatype then
      @options[:mediatype] = params[:mediatype]
    end

    if params.has_key? :size then
      @options[:size] = params[:size]
    end

    if params.has_key? :limit then
      @options[:limit] = params[:limit]
    end

    if params.has_key? :includeFirst then
      @options[:includeFirst] = params[:includeFirst]
    end

    if params.has_key? :author then
      @options[:author] = Persona.find(:all, :conditions => { :screen_name => params[:author]}).first
    end

    if params.has_key? :featured then
      if params[:featured] == 'true' then
        @options[:featured] = true
      elsif params[:featured] == 'false' then
        @options[:featured] = false
      else
        @options[:featured] = [true,false]
      end
    end

    upper = @options[:includeFirst] ? params[:last_id].to_i : params[:last_id].to_i - 1
    if @options[:mediatype] == 'photos' then
      @next_photos = Photo.find(:all, :conditions => { :id => 0..upper, :persona_id => @options[:author],
        :featured => @options[:featured] }, :order=>'id desc', :limit=> @options[:limit])
    elsif @options[:mediatype] == 'mediaset' then 
      #mediatype id should be mediaset
      @next_photos = Mediaset.find(params[:mediaset_id]).photos.find(:all, 
        :conditions => {:id => 0..upper }, :order => 'id desc', :limit=> @options[:limit])
    elsif @options[:mediatype] == 'trending' then
      #get the photos which attracts the most votes in a given time
    elsif @options[:mediatype] == 'tracked' then
      #get the photos that the current persona tracks
      @tracked_persona = current_persona.trackers.where(:tracked_object_type => 'persona')
      @next_photos = Photo.find(:all, :conditions => 
        { :id => 0..upper, :persona_id => @tracked_persona.pluck(:tracked_object_id)} , 
        :order => 'id desc', :limit => @options[:limit])
    end


    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST   /photos/toggle_featured/:photo_id(.:format)
  def toggle_featured
    @photo = Photo.find(params[:photo_id])
    @photo.toggle(:featured)
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
end
