# detech browser configuration
Rails.configuration.middleware.use Browser::Middleware do
  #TODO: need to allow css and other assets accessible
  redirect_to browser_unsupported_path unless 
    browser.safari? || browser.opera? || browser.chrome? || browser.mobile? || browser.tablet?
end
