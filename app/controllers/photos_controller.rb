class PhotosController < ApplicationController
  # GET /photos
  # GET /photos.json
  def index
    #show recent 40
    @photos = Photo.find(:all, :limit=> 50, :order => 'id desc')

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
        case params[:size]
          when 'xlarge'
            @avatar = @photo.avatar.xlarge
          when 'large'
            @avatar = @photo.avatar.large
          when 'medium'
            @avatar = @photo.avatar.medium
          when 'small'
            @avatar = @photo.avatar.small
          when 'tiny'
            @avatar = @photo.avatar.tiny
          when 'thumb50'
            @avatar = @photo.avatar.thumb50
          when 'thumb100'
            @avatar = @photo.avatar.thumb100
          when 'original'
            @avatar = @photo.avatar
          else
            @avatar = nil
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

    #navigation
    @prev_photos = Photo.find(:all,:conditions => "id > " + @photo.id.to_s + 
      " and persona_id == "+ @persona.id.to_s, :limit => 4 ).reverse
    @next_photos = Photo.find(:all,:conditions => "id < " + @photo.id.to_s + 
      " and persona_id == "+ @persona.id.to_s, :order => "id DESC", :limit => 8-@prev_photos.count )

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
end
