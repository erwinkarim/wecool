module PhotosHelper
  def get_photo_list(personaID, atPhotoID, mediasetID, isFeatured = [true, false])
    if mediasetID.nil? then
      if persona_signed_in? then 
        visibleScope = current_persona.id == personaID ? [true,false] : [true]
      else
        visibleScope = [true]
      end
      prev_photos = Photo.where{ (id.gt atPhotoID) & ( persona_id.eq personaID) & 
        (featured.in isFeatured) & (visible.in visibleScope) 
      }.limit(4).reverse
      next_photos =  Photo.where{ (id.lt atPhotoID) & (persona_id.eq personaID) &
        (featured.in isFeatured) & (visible.in visibleScope) 
      }.order('id desc').limit(8 - prev_photos.count)
    else
      current_photo_pos = Mediaset.find(mediasetID).mediaset_photos.where(:photo_id => atPhotoID).first.order
      prev_photos = Array.new
      next_photos = Array.new
      #prev_photos = Mediaset.find(mediasetID).photos.find(:all,:conditions => "photo_id > " + atPhotoID.to_s,
      #  :limit => 4 ).reverse
      prev_photos = Mediaset.joins{ mediaset_photos }.find(mediasetID).photos.
        where{ mediaset_photos.order.lt current_photo_pos }.order('"order"').reverse[0..3].reverse
      #next_photos = Mediaset.find(mediasetID).photos.find(:all,:conditions => "photo_id < " + atPhotoID.to_s, 
      #  :order => "id DESC", :limit => 8-prev_photos.count )
      next_photos = Mediaset.joins{ mediaset_photos }.find(mediasetID).photos.
        where{ mediaset_photos.order.gt current_photo_pos }.order('"order"').limit(8 - prev_photos.count) 
      if next_photos.count < 4 then
        #rebuild the photo selection
      prev_photos = Mediaset.joins{ mediaset_photos }.find(mediasetID).photos.
        where{ mediaset_photos.order.lt current_photo_pos }.order('"order"').reverse[0..(8 - next_photos.count)].reverse
      end
    end

    return prev_photos + Array.new.push(Photo.find(atPhotoID)) + next_photos
  end
end
