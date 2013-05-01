class StaticPageController < ApplicationController
  caches_page :tour

  def tour
  end
  
  def aboutUs
  end

  def termsAndConditions
  end
end
