class FollowersController < ApplicationController
  # GET    /followers/:persona_id(.:format)  
  def show
    @persona = Persona.find(:first, :conditions => { :screen_name => params[:persona_id] })
    @following = Persona.find(:all, 
      :conditions => { 
        :id => @persona.followers.where(:tracked_object_type => 'persona').pluck(:tracked_object_id) 
      })
    @followers = Persona.find(:all, :conditions=> { :id => Follower.where(:tracked_object_id => @persona.id, :tracked_object_type => 'persona').pluck(:persona_id)})
  end

  # POST   /followers/track/:object_type/:object_id
  def track
    @followed_persona = Persona.find(params[:object_id])
    @new_follower = current_persona.followers.new(:tracked_object_type => params[:object_type], 
      :tracked_object_id => params[:object_id], :relationship => 'contact')

    if @new_follower.save! then
      respond_to do |format|
        format.js
      end
    else
      redirect_to :back ,:notice => 'tracking failure' 
    end 
  end

  # POST   /followers/untrack/:object_type/:object_id  
  def untrack
    @followed_persona = Persona.find(params[:object_id])
    @follower = current_persona.followers.find(:first, :conditions => { :tracked_object_id => params[:object_id], :tracked_object_type => params[:object_type]})
    if @follower.destroy then
      respond_to do |format|
        format.js
      end
    else
      redirect_to :back, :notice => 'tracking failure'
    end
  end
end
