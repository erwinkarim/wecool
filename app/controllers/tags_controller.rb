class TagsController < ApplicationController
  def index
    #get recent tags
    #@tags = Photo.tag_counts.order('id desc').limit(20)

    #get recent tags for the last 24 hours, order by tag count
    @tags = Photo.get_tags 

    respond_to do |format|
      format.html { render "tags/index", :locals => { :tags => @tags, :persona => nil } }
    end
  end

  #GET    /tags/:tag_id
  def show
    @tag = params[:tag_id]
    @photos = Photo.tagged_with(@tag)

    respond_to do |format|
      format.html { render "tags/show", :locals => { :tag => @tag} }
    end
  end
  
  def get_more

    if params.has_key? :persona then
      @persona = Persona.find(params[:persona]) 
    end
    @tags = Photo.get_tags(params)

    respond_to do |format|
      format.html
      format.js
    end
  end
end
