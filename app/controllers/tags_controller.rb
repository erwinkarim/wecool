class TagsController < ApplicationController
  def index
    #get recent tags
    #@tags = Photo.tag_counts.order('id desc').limit(20)

    #get recent tags for the last 24 hours, order by tag count
    @tags = Photo.joins{ 
      taggings 
    }.group{
      taggings.created_at 
    }.having{ 
      taggings.created_at.in 1.day.ago..1.minute.ago 
    }.tag_counts.order('"count" desc') 

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
