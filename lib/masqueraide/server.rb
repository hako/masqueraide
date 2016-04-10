# Masqueraide server, possibly for bot management.

require 'sinatra/base'

module Masqueraide
  # Masqueraide server powered by Sinatra.
  class Server < Sinatra::Application
    
    # We need to set the views folder to /views 
    # so that we can load the assets when serving endpoints.
  	configure do
  		set :public_folder, File.dirname(__FILE__) + '/views'
  	end
    
    # Serve the homepage.
    get '/'	do
      erb :index
    end
  end
end
