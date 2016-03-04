# Masqueraide server, possibly for bot management.

require 'sinatra/base'

module Masqueraide
	class Server < Sinatra::Application
	get '/'	do
		'M A S Q U E R A I D E'
	end
	end
end