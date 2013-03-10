class TrackersController < ApplicationController
  # POST   /trackers/track/:object_type/:object_id
  def track
    @tracked_persona = Persona.find(params[:object_id])
    @new_tracker = current_persona.trackers.new(:tracked_object_type => params[:object_type], 
      :tracked_object_id => params[:object_id], :relationship => 'contact')

    if @new_tracker.save! then
      respond_to do |format|
        format.js
      end
    else
      redirect_to :back ,:notice => 'tracking failure' 
    end 
  end

  # POST   /trackers/untrack/:object_type/:object_id  
  def untrack
    @tracked_persona = Persona.find(params[:object_id])
    @tracker = current_persona.trackers.find(:first, :conditions => { :tracked_object_id => params[:object_id], :tracked_object_type => params[:object_type]})
    if @tracker.destroy then
      respond_to do |format|
        format.js
      end
    else
      redirect_to :back, :notice => 'tracking failure'
    end
  end
end
