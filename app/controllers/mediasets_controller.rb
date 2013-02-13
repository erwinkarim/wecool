class MediasetsController < ApplicationController
  # GET /mediasets
  # GET /mediasets.json
  def index
    @mediasets = Mediaset.find(:all, :limit =>10, :order => 'id desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mediasets }
    end
  end

  # GET /mediasets/persona_id
  # GET /mediasets/persona_id.json
  def show
    #@mediaset = Mediaset.find(params[:id])
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:id] }).first
    @default_photos = @persona.photos.find(:all, :order => 'id desc', :limit => 9)
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
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mediaset }
    end
  end

  # GET /mediasets/1/edit
  # GET /mediasets/:persona_id/edit/:id(.:format)
  def edit
    @mediaset = Mediaset.find(params[:id])
    @mediaset_photos = @mediaset.photos
    @photos = Photo.find(:all, :order => 'id desc',  :conditions => {
      :persona_id => Persona.find(:first, :conditions => {:screen_name => params[:persona_id]} )
    })
  end

  # POST /mediasets
  # POST /mediasets.json
  def create
    #@mediaset = Mediaset.new(params[:mediaset])
    if persona_signed_in? then
      @mediaset = current_persona.mediasets.new(params[:mediaset])
    end

    respond_to do |format|
      if @mediaset.save
        format.html { redirect_to edit_mediaset_path(current_persona.screen_name, @mediaset),
           notice: 'Mediaset was successfully created.' }
        format.json { render json: @mediaset, status: :created, location: @mediaset }
      else
        format.html { render action: "new" }
        format.json { render json: @mediaset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mediasets/1
  # PUT /mediasets/1.json
  def update
    @mediaset = Mediaset.find(params[:id])

    respond_to do |format|
      if @mediaset.update_attributes(params[:mediaset])
        format.html { redirect_to @mediaset, notice: 'Mediaset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mediaset.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /mediasets/:mediaset_id/update_photos(.:format)
  def update_photos
    @mediaset = Mediaset.find(params[:mediaset_id]) 
    @current_selection = @mediaset.photos
    @new_selection = Photo.find(params[:photo])

    if @current_selection.empty? then
      @new_selection.each do |photo|
        @mediaset.mediaset_photos.create(:photo_id => photo.id)
      end
    else
      #add new selections
      @new_selection.each do |photo|
        if !@current_selection.include?(photo) then
          @mediaset.mediaset_photos.create(:photo_id => photo.id)
        end
      end

      #delete the ones that was once there, but not selected anymore
      @current_selection.each do |photo|
        if !@new_selection.include?(photo) then
          @mediaset.mediaset_photos.destroy(@mediaset.mediaset_photos.find(:all, :conditions => {:photo_id => photo.id}))
        end
      end
    end

    redirect_to view_sets_path(current_persona.screen_name, @mediaset), notice: 'Mediaset Updated'
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
    @mediaset_photos = @mediaset.photos.find(:all, :order => 'id desc')
  end
end