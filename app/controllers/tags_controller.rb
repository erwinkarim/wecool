class TagsController < ApplicationController
  def index
    #get recent tags
    @tags = Photo.tag_counts.order('id desc').limit(20)

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
end
