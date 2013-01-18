class PhotosController < ApplicationController
  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.find(:all, :limit=> 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    #it's actually showing photos generated by a persona
     
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:id]}, :limit => 1 ).first
    @photos = Photo.find(:all, :conditions=> { :persona_id => @persona.id}, :limit => 20 )

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

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

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render json: @photo, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
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
          when 'original'
            @avatar = @photo.avatar
          else
            @avatar = nil
        end
      else
        @avatar = @photo.avatar.xlarge  
    end
  end

  def editor
    @photo = Photo.find(params[:photo_id])
  end

  def view
    @photo = Photo.find(params[:id])
    @persona = Persona.find(@photo.persona_id)

    #navigation
    @photo_prev = Photo.find(:all,:conditions => "id < " + @photo.id.to_s + 
      " and persona_id == "+ @persona.id.to_s, :order => "id DESC" ).first
    @photo_next = Photo.find(:all,:conditions => "id > " + @photo.id.to_s + 
      " and persona_id == "+ @persona.id.to_s , :limit => 1).first

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @photo }
    end
  end
end
