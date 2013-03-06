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
  
  def get_photo_list(personaID, atPhotoID, mediasetID)
    if mediasetID.nil? then
      prev_photos = Photo.find(:all,:conditions => "id > " + atPhotoID.to_s + 
        " and persona_id == "+ personaID.to_s, :limit => 4 ).reverse
      next_photos = Photo.find(:all,:conditions => "id < " + atPhotoID.to_s + 
        " and persona_id == "+ personaID.to_s, :order => "id DESC", :limit => 8-prev_photos.count )
    else
      prev_photos = Mediaset.find(mediasetID).photos.find(:all,:conditions => "photo_id > " + atPhotoID.to_s,
        :limit => 4 ).reverse
      next_photos = Mediaset.find(mediasetID).photos.find(:all,:conditions => "photo_id < " + atPhotoID.to_s, 
        :order => "id DESC", :limit => 8-prev_photos.count )
      if next_photos.count < 4 then
        #rebuild the photo selection
        prev_photos = Mediaset.find(mediasetID).photos.find(:all,:conditions => "photo_id > " + atPhotoID.to_s,
          :limit => 8-next_photos.count ).reverse
      end
    end

    return prev_photos + Array.new.push(Photo.find(atPhotoID)) + next_photos
  end
end
