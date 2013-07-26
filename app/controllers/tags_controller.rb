class TagsController < ApplicationController
  def index
    #all content loaded by ajax
    
    js :params => { :persona => 0 }

    respond_to do |format|
      format.html { render "tags/index", :locals => { :tags => @tags, :persona => nil } }
    end
  end

  #GET    /tags/:tag_id
  def show
    @tag = params[:tag_id]
    @photos = Photo.tagged_with(@tag)

		js :params => { :persona => '', :tag => @tag }

    respond_to do |format|
      format.html { render "tags/show", :locals => { :tag => @tag} }
    end
  end
  
  # GET    /tags/get_more(.:format)
  def get_more
    current_options = params.inject({}){ |memo, (k,v)| memo[k.to_sym] = v; memo }
    if params.has_key? :persona_range then
      @persona = Persona.find(params[:persona_range]) 
    end
    @tags = Photo.get_tags(current_options)

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  #get and show related photos
  # GET    /tags/related/:photo_id
  def related
    @photo = Photo.find(params[:photo_id])
    @related_photos = @photo.find_related_tags.limit(8)
    
		js :params => { :photo_id => @photo.id }
    respond_to do |format|  
      format.html
    end
  end
end
