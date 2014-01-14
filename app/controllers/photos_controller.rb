class PhotosController < ApplicationController
  #include Twitter::Extractor
  before_filter :check_if_allowed_to_view, :only => [:view, :download]
  before_filter :check_if_allowed_to_visible, :only => [:toggle_visible]
  before_filter :check_if_reach_quota, :only => [:create]
  before_filter :authenticate_persona!, :only => [:new, :edit, :editor, :new_direct]
	before_filter :check_for_mobile

  #how many free photos you can actually have
  FREE_PHOTO_LIMIT = 1000
  FREE_BANDWIDTH_LIMIT = 300

  def check_if_allowed_to_view
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @photo = @persona.photos.find(params[:id])
     if (!@photo.visible && current_persona != @persona) || !@photo.system_visible then
      respond_to do |format|
        format.html { render :not_viewable }
      end
    end
  end

  def check_if_allowed_to_visible
    @persona = Persona.where(:screen_name => params[:persona_id]).first
    unless @persona.permium? then
      respond_to do |format|
        format.html { render :text => 'Upgrade to premium' }
      end
    end
  end

  #every time upload, check if can send photos
  def check_if_reach_quota
    if current_persona.storage_usage > current_persona.current_storage_size then
      error_msg = 
          [{ :files => 
            [{
              "name" => "Bandwidth exceeded", 
              "error" => "Bandwidth exceeded",
              "size" => 1000, 
              "url" => '',
              "thumbnail_url" => '/assets/icon/zero-photo/square100.jpg', 
              "delete_url" => '', 
              'name' => 'square100.jpg', 
              "delete_type" => "DELETE",
            }]
          }].to_json
      respond_to do |format|
        format.html { render :json => error_msg, :content_type => 'text/html', :layout => false }
        format.json { render :json => error_msg, :status => :unauthorized } 
      end
    end
  end

  def check_if_signed_in
    unless persona_signed_in? then
      flash[:error] = 'You must sign in first'
      redirect_to new_persona_session_path    
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
    #@persona = Persona.find(:all, :conditions => { :screen_name => params[:persona_id]}, :limit => 1 ).first
    @persona = Persona.where(:screen_name => params[:id]).first

    #check if some of the photos are invisible 
    if persona_signed_in? && @persona == current_persona then
      if !current_persona.photos.where(:system_visible => false).empty? then
        flash[:warning] = 'Some photos are not visible because you have exceed the free photos limit of ' + 
          FREE_PHOTO_LIMIT.to_s + ' photos. <a href="' + persona_upgrade_acc_path(@persona.screen_name) + 
          '">Upgrade</a> to see them all!'
      end
    end
  

    if @persona.nil? then
      respond_to do |format|  
        format.html { render :text => 'Persona does not exists' }
      end
    else 
      @last_photo = @persona.photos.empty? ? Photo.new : @persona.photos.last
      js :params =>{ :last_photo_id => @last_photo.id, :persona => @persona.screen_name }
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @persona.photos }
      end
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = current_persona.photos.new(params[:photo])
    @persona = current_persona
    if !@persona.premium then
      @storage_usage = @persona.storage_usage    
      @storage_size = @persona.current_storage_size*1024*1024*1024
      if @storage_usage > @storage_size*0.8 && @storage_usage < @storage_size then
        flash[:warning] = 'You are using more than 80% of your monthly quota. <a href="'+
          persona_upgrade_acc_path(@persona.screen_name) + '">Upgrade</a> if you plan to use more space'
      elsif @storage_usage > @storage_size then
        flash[:error] = 'You have exceeded your monthly quota and you may no longer load ' + 
          'any more photos for this month unless you <a href="' + persona_upgrade_acc_path(@persona.screen_name) +
          '">upgrade</a> to premium'
      end
    end
    #@photo = Photo.new

    js :params  => { :get_dups_path => photos_get_dups_path(@persona.screen_name ) }

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
    #logger.debug 'Avatar dump:' + params[:photo][:avatar].tempfile.path
    #File.open(Rails.root + 'param_dump.txt', 'w') do |f|
    #  f.write(params.to_s)
    #end

    @photo = current_persona.photos.new(params[:photo])
    @photo.system_visible = true
    @photo.title = @photo.avatar.to_s.split('/').last
  
    if params.has_key? :visible then 
      @photo.visible = false
    end

    respond_to do |format|
      if @photo.save
        @photo.reset_tags

        #add the mediasets
        if params.has_key? :mediaset then 
          @photo.update_setlist params[:mediaset]
        end

        #generate md5 key
        @photo.gen_md5 params[:photo][:avatar].tempfile.path
 
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
        #format.json { head :no_content }
        format.json { respond_with_bip(@photo) }
      else
        format.html { render action: "edit" }
        #format.json { render json: @photo.errors, status: :unprocessable_entity }
        format.json { respond_with_bip(@photo) }
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
      @avatar = @photo.avatar.large  
      params[:size] = 'large'
    end
  end

  # GET    /photos/:persona_id/editor/:photo_id(.:format) 
  def editor
    @photo = Photo.find(params[:photo_id])
    @persona = Persona.find(@photo.persona_id)

    #store in cache so can get height/width
    if !@photo.avatar.cache_name then
      @photo.avatar.cache_stored_file!
      @photo.avatar.retrieve_from_cache! @photo.avatar.cache_name
    end
    
    js :params => { 
      :img_src => @photo.avatar.large.url, :img_height => @photo.avatar.large.height, 
      :img_width => @photo.avatar.large.width, :persona => @persona.screen_name, :photo_id =>@photo.id, 
      :photo_title => @photo.title 
    } 
  end
  
  #  POST   /photos/:persona_id/editor/:photo_id/generate
  #   generate the photo from canvas.toDataPath in jpg format to physical file and send it out to client
  #
  # parameters:-
  #     imagedata canvas.toDataURL()
  #     filename  the file name to send the data as
  def editor_gen
    #need to optimize this
    send_data Base64.decode64(params[:imagedata]), { :filename => params[:filename] , :disposition => 'attachment' }  
  end

  # POST   /photos/:persona_id/editor/:photo_id/upload_to_sys
  # upload canvas data to the system (generate a new picture in the system)
  # parameters:-
  #   imagedata canvas.toDataURL()
  def editor_upload_to_sys
    @old_photo = Photo.find(params[:photo_id])
    thisFile = File.new('/tmp/' + SecureRandom.urlsafe_base64 + '.jpg' , 'w+')
    if thisFile
      thisFile.syswrite( Base64.decode64(params[:imagedata]) )
    end

    @photo = Persona.where(:screen_name => params[:persona_id]).first.photos.new
    @photo.avatar = thisFile
    @photo.title = @old_photo.title.gsub(/.[jJ][pP][gG]/, '_edited')
    @photo.system_visible = true
    if @photo.save then
      flash[:warning] = 'File created'
      respond_to do |format|
        format.js
        format.html
      end
    else
      render :status => :internal_server_error
    end
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

    #capture addional info
    #@exif = EXIFR::JPEG.new(@photo.avatar.path).exif
    if @photo.exif
      @exif = YAML.load @photo.exif
    else
      @exif = nil
    end

    #setup javascript 
    js :params => { :mediaset_ids => @photo.mediasets.map{ |x| x.id }, :photo_id => @photo.id, 
      :screen_name => @persona.screen_name , :prev_photo_path => @prev_photo_path, 
      :next_photo_path => @next_photo_path, :featured_photo => @photo.featured? ,
      :persona_signed_in =>  persona_signed_in? && @persona.id == current_persona.id
    }

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @photo.to_jq_upload.to_json, status: :created, location: @photo }
			format.xml { render xml: @photo } 
    end
  end

  # GET /photos/:persona_id/view/:id/exif(.:format)
  def view_exif
    #view exif data of this photo
    @photo = Photo.find(params[:id])
    @persona = Persona.find(@photo.persona_id)
    #@exif = EXIFR::JPEG.new(@photo.avatar.path).exif
    @exif = @photo.exif.nil? ? nil : YAML.load(@photo.exif)

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
  # GET    /photos/get_more/:last_id
  def get_more

    # convert from { "key" => "value" } to { :key => "value" }
    current_options = params.inject({}){ |memo, (k,v)| memo[k.to_sym] = v; memo }
    if params.has_key? :photoFocusID then
      @current_photo = Photo.find(params[:photoFocusID])
    else
      @current_photo = nil
    end

    #fetch the photos
    results = Photo.get_more( 
      params[:last_id].to_i, 
      current_options, 
      { :signed_in? => persona_signed_in? , :current_persona => current_persona }
    )

    @options = results[:options]
    @next_photos = results[:photos]

    #set the svg height
    case @options[:size]
    when 'width1200'
      @vector_height = '1200px'
    when 'xlarge'
      @vector_height = '1000px'
    when 'width980'
      @vector_height = '980px'
    when 'large'
      @vector_height = '800px'
    when 'width767'
      @vector_height = '767px'
    when 'width480'
      @vector_height = '480px'
    when 'medium'
      @vector_height = '600px'
    when 'small'
      @vector_height = '400px'
    when 'tiny' 
      @vector_height = '200px'
    when 'square200' 
      @vector_height = '200px'
    when 'square100' || 'thumb100'
      @vector_height = '100px'
    when 'square50' || 'thumb50'
      @vector_height = '50px'
    else
      @vector_height = '512px'
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

    #available on #paper trail 2.7.2 (unreleased yet)
    #@photo.paper_trail_event = @photo.featured? ? 'featured' : 'unfeatured' 

    if @photo.save then
      respond_to do |format|
        format.js
        format.html
      end
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

  # GET    /photos/:persona_id/not_viewable(.:format)
  # tells the user that the photo is not viewable because of owner/system restrictions
  def not_viewable
  end

  # POST   /photos/:persona_id/clear_from_queue/:photo_id
  # clear from the queue in :new action
  def clear_from_upload_queue
  end
  
  #  POST   /photos/:persona_id/share
  # required parameters in params:-
  #   :url          the url that will be shared
  #   :photoList    html coded list of photos
  #   :mode         in what way that this photo will be shared valid options:-
  #                   email   share via email, required variables are 
  #                           :email - list of email to be send
  #                           :description - additional description to be written in the email
  def share 
    if params[:mode] == 'email' then
      #send email about sharing this photo :url from :persona_id
      options = { :to => params[:email], :url => params[:url], :message => params[:description], 
        :photoList => params[:photoList] }

      #format email and the send it out
      AppMailer.share( options ).deliver

    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET    /photos/:persona_id/dl_test
  def dl_test
  end

  # get list of dups based that :persona_id has based on :md5 given
  #  GET    /photos/:persona_id/get_dups(.:format)
  #   expected options: 
  #     :md5       md5 that we are looking for
  def get_dups
    @persona = Persona.where( :screen_name => params[:persona_id] ).first
    @dups = @persona.photos.where( :md5 => params[:md5] )

    respond_to do |format|
      format.json { render :json => @dups }
    end 
  end

	#GET    /photos/:persona_id/new_direct(.:format)
  #direct upload to s3 test
  def new_direct
    @persona = current_persona
    js :params => { :persona_id => params[:persona_id] } 
  end

	#GET    /photos/:persona_id/gen_s3_data
	#generate the necessary data to upload directly to amazon S3
	def gen_s3_data
    render :json => {
      :policy => s3_upload_policy_document, 
      :signature => s3_upload_signature, 
      :key => "uploads/temp/#{SecureRandom.uuid}/#{params[:doc][:title]}",
      :success_action_redirect => photos_gen_from_s3_url(params[:persona_id])
    }
	end

	#POST   /photos_direct(.:format) 
	#after done uploading to S3, create a new carrierwave object to load it from s3, should be very fast since it's all 
	# in the same area at amazon DC. 
  def create_direct
    @photo = current_persona.photos.new
    @photo.system_visible=true
    @photo.save!

    render :json => {
      :policy => s3_upload_policy_document, 
      :signature => s3_upload_signature, 
      :key => "uploads/photo/avatar/#{@photo.id}/#{params[:doc][:title]}",
      :success_action_redirect => phtotos_gen_from_s3_url(current_persona.screen_name)
    }
  end

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    return @policy if @policy
    ret = {"expiration" => 5.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      "conditions" =>  [ 
        {"bucket" =>  ENV['S3_BUCKET_NAME']}, 
        ["starts-with", "$key", 'uploads/temp'],
        {"acl" => "private"},
        {"success_action_status" => "201"}
      ]
    }
    @policy = Base64.encode64(ret.to_json).gsub(/\n|\r/,'')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    signature = Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'), 
        ENV['AWS_SECRET_ACCESS_KEY'], 
        s3_upload_policy_document
      )
    ).gsub("\n","")
  end

  #generate a photo object after successfully uploaded to S3
  # POST    /photos/:persona_id/gen_from_s3
  def gen_from_s3
		location = Hash.from_xml( params[:responseText] )['PostResponse']['Location'] 
		Photo.delay.generate_from_s3 current_persona, location, { :title => URI.decode(location).split('/').last, 
      :description => params[:description] } 

    File.open(Rails.root + 'param_dump.txt', 'w') do |f|
      f.puts(params.to_s)
    end
	
		#grab from s3
		#:@photo.remote_avatar_url = Hash.from_xml( params[:responseText] )['PostResponse']['Location'] 

		respond_to do |format|
  		format.json { render :json => { 
  		  :location => Hash.from_xml(params[:responseText])['PostResponse']['Location'] } }
			#if @photo.save
			#	format.json { render :json => @photo.to_jq_upload.to_json, status: :created, location: @photo  }
			#else
      #  format.json { render json: @photo.errors, status: :unprocessable_entity }
			#end
		end
  end
end
