# detech browser configuration
Rails.configuration.middleware.use Browser::Middleware do
  #TODO: need to allow css and other assets accessible
  if browser.ie? then
    redirect_to browser_unsupported_path 
  end
end
