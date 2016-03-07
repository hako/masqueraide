# Masqueraide server, possibly for bot management.

require 'sinatra/base'

module Masqueraide
  # Masqueraide server powered by Sinatra.
  class Server < Sinatra::Application

  	configure do
  		set :public_folder, File.dirname(__FILE__) + '/views'
  	end

    get '/'	do
      erb :index
    end
  end
end
