class StaticPageController < ApplicationController
  caches_page :tour

  def tour
  end
end
