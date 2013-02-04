class MediasetsController < ApplicationController
  # GET /mediasets
  # GET /mediasets.json
  def index
    @mediasets = Mediaset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mediasets }
    end
  end

  # GET /mediasets/persona_id
  # GET /mediasets/persona_id.json
  def show
    #@mediaset = Mediaset.find(params[:id])
    @persona = Persona.find(:all, :conditions => (:screen_name == params[:id])).first 
    @mediasets = Mediaset.find(:all, :conditions => (:persona_id == @persona.id))

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
  def edit
    @mediaset = Mediaset.find(params[:id])
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
        format.html { redirect_to @mediaset, notice: 'Mediaset was successfully created.' }
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

  def view
    @persona = Persona.find(:all, :conditions => ( :screen_name == params[:persona_id])).first
    @mediaset = @persona.mediasets.find(params[:id])
    @mediaset_photos = MediasetPhoto.find(:all, :conditions => {:mediaset_id => @mediaset.id})
  end
end
