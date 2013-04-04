module PhotosHelper
  def build_page_list(current_page, total_page, persona)
    @returnString = String.new


    @returnString = '<ul>'
    @returnString = @returnString + '<li>' +  
      link_to('Prev', current_page == 1 ? '#' : photo_page_path(persona.screen_name, current_page - 1)) + 
        '</li>'
    if total_page < 10 then
      for page in 1..total_page
        @returnString = @returnString + build_page_bullet(page, current_page , persona)
      end
    else
      if current_page < 4 then
        #build the first 3
        for page in 1..3 
          @returnString = @returnString + build_page_bullet(page, current_page , persona)
        end
        #build the ...
        @returnString = @returnString + '<li><a href="#">...</a></li>'
        #build the last 3
        for page in (total_page-3)..total_page
          @returnString = @returnString + build_page_bullet(page, current_page , persona)
        end
      elsif current_page > (total_page-4) then
        #build the first
        @returnString = @returnString + build_page_bullet(1, current_page , persona)
        #build the ...
        @returnString = @returnString + '<li><a href="#">...</a></li>'
        #build the last 4
        for page in (total_page-3)..total_page
          @returnString = @returnString + build_page_bullet(page, current_page , persona)
        end
      else
        #current page > 3
        #build the first
        @returnString = @returnString + build_page_bullet(1, current_page , persona)
        #build the ...
        @returnString = @returnString + '<li><a href="#">...</a></li>'
        #build the middle 3
        for page in (current_page-1)..(current_page+1)
          @returnString = @returnString + build_page_bullet(page, current_page , persona)
        end
        #build the ...
        @returnString = @returnString + '<li><a href="#">...</a></li>'
        #build the last
        @returnString = @returnString + build_page_bullet(total_page, current_page , persona)
      end
    end
    @returnString = @returnString + '<li>' + 
      link_to('Next', 
        @current_page == @page_count ? '#' : photo_page_path(persona.screen_name, current_page + 1)) + 
      '</li>'
    @returnString = @returnString + '</ul>'
    return @returnString.html_safe
  end
  
  def build_page_bullet(this_page, current_page, persona)
    @returnString = String.new
    @returnString = @returnString + (this_page.to_i == current_page.to_i ? '<li class="active">' : '<li>') + 
      link_to(this_page, photo_page_path(persona.screen_name, this_page)) + '</li>'
    return @returnString.html_safe
  end
  
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
