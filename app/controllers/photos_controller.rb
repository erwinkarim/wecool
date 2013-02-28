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
    @page_count = (@persona.photos.count.to_f/10).ceil

    if params.has_key? :page_id then
      #show the current page in the set/album
      @photos = Photo.find(:all, 
        :conditions=> { :persona_id => @persona.id}, :limit => 10, 
          :offset => (params[:page_id].to_i-1) * 10 ,  :order=> 'id desc' )
      @current_page = params[:page_id].to_i
    else
      @photos = Photo.find(:all, 
        :conditions=> { :persona_id => @persona.id}, :limit => 10, :order=> 'id desc' )
      @current_page = 1
    end

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
  def get_more
   
    @options = {
      :media_type => 'photos', :size => 'tiny',
      :limit => 10
    }

    if params.has_key? :media_type then
      @options[:media_tye] = params[:media_type]
    end

    if params.has_key? :size then
      @options[:size] = params[:size]
    end

    if params.has_key? :limit then
      @options[:limit] = params[:limit]
    end

    if params[:media_type].nil?  then
      @next_photos = Photo.find(:all, :conditions => "id < " + params[:last_id], :order=>'id desc', 
        :limit=> @options[:limit])
    else
      #media_type id should be mediaset
      @next_photos = Mediaset.find(params[:mediaset_id]).photos.find(:all, 
        :conditions => "photo_id < " + params[:last_id], :order => 'id desc', :limit=> @options[:limit])
    end


    respond_to do |format|
      format.js
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
end
