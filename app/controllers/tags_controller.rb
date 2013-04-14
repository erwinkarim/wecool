class TagsController < ApplicationController
  def index
    #get recent tags
    @tags = Photo.tag_counts.order('id desc').limit(20)
  end

  #GET    /tags/:tag_id
  def show
    @tag = params[:tag_id]
    @photos = Photo.tagged_with(@tag)
  end
end
