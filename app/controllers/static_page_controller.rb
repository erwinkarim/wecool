class StaticPageController < ApplicationController
  caches_page :tour

  def tour
  end
  
  def aboutUs
  end

  def termsAndConditions
  end

  def browser_unsupported 
    render :layout => 'test'
  end

	def about_wecool
	end
	
	def organize_photo
	end

	def online_editing
	end

end
