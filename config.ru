# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
if Rails.env.production? then
  #caching purpose
  use Rack::Static, :urls => ['/carrierwave_cache'], :root => 'tmp' # adding this line
end
run Wecool::Application
