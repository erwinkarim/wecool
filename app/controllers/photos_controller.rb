class PhotosController < ApplicationController
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

  def editor
    @photo = Photo.find(params[:photo_id])
    @persona = Persona.find(@photo.persona_id)
  end

  def view
    @persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id] }).first
    @photo = @persona.photos.find(params[:id])

    @total_votes = @photo.up_votes + @photo.down_votes
    @mediasets = @persona.mediasets

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
    @current_selection = @photo.mediasets
    @new_selection = Mediaset.find(params[:mediaset])

    if @current_selection.empty? && !@new_selection.empty? then
      @new_selection.each do |mediaset|
        @photo.mediaset_photos.create(:mediaset_id => mediaset.id, :order => 1)
      end
    elsif !@current_selection.empty? && !@new_selection.empty? then
      #add new selection
        @new_selection.each do |mediaset|
          if !@current_selection.include?(mediaset) then
            @photo.mediaset_photos.create(
              :mediaset_id => mediaset.id, 
              :order => Mediaset.find(mediaset).mediaset_photos.pluck('"order"').max + 1 
            )
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

    #default options
    @options = {
      #fetch options
      :mediatype => 'photos', :limit => 10, :includeFirst => false, :author => 0..Persona.last.id, 
      :featured => [true, false], :excludeMediaset => 0,
      :excludeLinks => false, :dateRange => 50.years.ago..DateTime.now, 

      #view options
      :draggable => false, :dragSortConnect => nil , :enableLinks => true, :size => 'tiny',
      :showCaption => true, :float => true, :cssDisplay => 'inline'
    }

    #modify options
    if params.has_key? :mediatype then
      @options[:mediatype] = params[:mediatype]
    end

    if params.has_key? :size then
      @options[:size] = params[:size]
    end

    if params.has_key? :limit then
      @options[:limit] = params[:limit].to_i
    end

    if params.has_key? :includeFirst then
      @options[:includeFirst] = params[:includeFirst] == 'true' ? true : false
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

    if params.has_key? :showCaption then
      if params[:showCaption] == 'false' then
        @options[:showCaption] = false
      end
    end

    if params.has_key? :excludeLinks then
      if params[:excludeLinks] == 'false' then
        @options[:excludeLinks] = false
      end
    end

    if params.has_key? :dateRange then
      @theDate = DateTime.parse params[:dateRange]
      @options[:dateRange] = @theDate..@theDate+1
    end

    if params.has_key? :excludeMediaset then
      if params[:excludeMediaset].empty? then
        @excluded_mediaset_photos = 0
      else
        @excluded_mediaset_photos = Mediaset.find(params[:excludeMediaset]).photos.pluck(:photo_id)
      end
    else
      @excluded_mediaset_photos = 0
    end

    if params.has_key? :draggable then
      @options[:draggable] = params[:draggable] == 'true' ? true : false
    end

    if params.has_key? :dragSortConnect then
      @options[:dragSortConnect] = params[:dragSortConnect]
    end

    if params.has_key? :enableLinks then
      @options[:enableLinks] = params[:enableLinks] == 'false' ? false : true
    end

    if params.has_key? :float then
      @options[:float] = params[:float] == 'false' ? false : true
    end

    if params.has_key? :cssDisplay then
      @options[:cssDisplay] = params[:cssDisplay]
    end

    #fetch photos
    if ['photos', 'featured'].include? @options[:mediatype] then 
      upper = @options[:includeFirst] ? params[:last_id].to_i : params[:last_id].to_i - 1
    else
      upper = @options[:includeFirst] ? params[:last_id].to_i : params[:last_id].to_i + 1  
    end

    if @options[:mediatype] == 'featured' then
      #load featured photos
      @next_photos = Photo.where{
        (id.in 0..upper) & (featured.eq true)
      }.order('id desc').limit(@options[:limit])
    elsif @options[:mediatye] == 'featured' || @options[:mediatype] == 'photos' then
      #@next_photos = Photo.find(:all, :conditions => { 
      #    :id => 0..upper, :persona_id => @options[:author],
      #    :featured => @options[:featured], :created_at => @options[:dateRange]
      #  }, 
      #  :order=>'id desc', :limit=> @options[:limit],
      #  :group => 'id', :having => ['id not in (?)', @excluded_mediaset_photos ]
      #)
      persona_range = @options[:author]
      feature_range = @options[:featured]
      date_range = @options[:dateRange]
      thisPersona = persona_signed_in? ? current_persona.id : 0 
      excluded_sets = @excluded_mediaset_photos
      persona_photos = Photo.where{ persona_id.eq thisPersona }
      other_photos = Photo.where{ (persona_id.not_eq thisPersona ) & (visible.eq true) }
      @next_photos = Photo.where{
        (id.in(persona_photos.select{id})) | (id.in(other_photos.select{id}))
      }.group(:id).having{
        (id.in 0..upper) & (persona_id.in persona_range) & (featured.in feature_range) &
        (created_at.in date_range) & (id.not_in excluded_sets)
      }.order('id desc').limit(@options[:limit])
    elsif @options[:mediatype] == 'mediaset' then 
      #mediatype id should be mediaset
      #@next_photos = Array.new
      #@mediaset_photos = Mediaset.find(params[:mediaset_id]).mediaset_photos.where(
      #  :order => upper..upper+@options[:limit] ).order(:order).pluck(:photo_id)
      #@mediaset_photos.each do |photo_id| 
      #  @next_photos.push Photo.find(photo_id)
      #end
      #@next_photos = Mediaset.joins{ mediaset_photos }.find(params[:mediaset_id]).photos.order('"order"').
      #  where( "mediaset_photos.order" => upper..upper+@options[:limit])
      
      order_range = upper..upper+@options[:limit]
      #if you the owner of the set, you can see all photos, otherwise, only that the ones that you allowed to
      # see
      if persona_signed_in? && current_persona.id == Mediaset.find(params[:mediaset_id]).persona_id then
        visibility = [true,false]
      else
        visibility = true
      end
      @next_photos = Mediaset.joins{ mediaset_photos }.find(params[:mediaset_id]).photos.where{
        mediaset_photos.order.in order_range
      }.order('mediaset_photos."order"').group('mediaset_photos."order"').having(:visible => visibility)
    elsif @options[:mediatype] == 'trending' then
      #get the photos which attracts the most votes in a given time
      @next_photos = Photo.joins{ votings }.order("votings.created_at desc").limit(@options[:limit]).
        offset(params[:last_id]).uniq
    elsif @options[:mediatype] == 'tracked' then
      #get the photos that the current persona tracks
      @tracked_persona = current_persona.followers.where(:tracked_object_type => 'persona')
      @next_photos = Photo.find(:all, :conditions => 
        { :id => 0..upper, :persona_id => @tracked_persona.pluck(:tracked_object_id), :visible=>true} , 
        :order => 'id desc', :limit => @options[:limit])
    end


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
    @photo_handle = Photo.new
    if persona_signed_in? && current_persona.screen_name == params[:persona_id] then
      @photo_handle = Photo.find(params[:photo_id])
      @photo = Magick::Image.read(@photo_handle.avatar.path).first
      if params[:method] == 'rotate' then
        if params[:direction] == 'left' then
          puts 'rotate left'
          @photo.rotate!(-90)
        elsif params[:direction] == 'right' then
          @photo.rotate!(90)
        end
      end    
      @photo.write(@photo_handle.avatar.path)
    
      #todo, update only the current one, recreate in background
      @photo_handle.avatar.recreate_versions!
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
