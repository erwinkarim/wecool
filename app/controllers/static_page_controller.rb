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
end
