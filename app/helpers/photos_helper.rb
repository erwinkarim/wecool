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
  
  def build_photo_coverflow(current_photo_id, mediaset_id)
    #like page list, but of photos
    if mediaset_id.nil? then
    else
    end
  end
end
