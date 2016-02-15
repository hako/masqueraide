# The Snapchat Room for Masqueraide AI bots.

require 'faraday'
require 'jwt'
require 'json'

module Masqueraide
	module Room
		class Snapchat
			NAME = "Snapchat"
			@@ais_in_room = []
			def initialize
			end

			# Set AI to the room.
			def set_ai(ai)
				@ai = ai
				@@ais_in_room << @ai
			end

			# Fetch an AI from the room.
			def ai(name)
				ai = @@ais_in_room.select { |ai| ai.username == name }
				return ai[0]
			end
		class API
			CASPER_ENDPOINT = "https://casper-api.herokuapp.com"

			# The Snapchat API, brought to you by @liamcottle of Casper.
			def initialize(api_key, api_secret)
				@api_key = api_key
				@api_secret = api_secret
			end

			# Login into Snapchat using Casper and fetch the url.
			def login(username, password)
				data = {
					"username" => username,
 					"password" => password
				}
				response = casper_login(username, password)
				puts response["url"]
			end

			private
			# Low Level API Library for Snapchat API & Casper API.

			# Login into Casper.
			def casper_login(username, password)
				data = {
					"username" => username,
 					"password" => password
				}
				jwt = sign_token(data)
				res = validate_token('/snapchat/ios/login', {"jwt" => jwt})
				return JSON.parse(res.body)
			end

			# Sign the parameters with HS256 (HMAC-SHA256).
			def sign_token(params)
				time = Time.now.to_f.to_s
				data = {"iat" => time}
				data.merge!(params) unless params.nil?
				token = JWT.encode data, @api_secret, 'HS256'
				return token
			end

			# Validate the generated token with the Casper API.
			def validate_token
				fctx = Faraday.new(:url => CASPER_ENDPOINT) do |f|
					f.adapter Faraday.default_adapter
					f.response :logger
					f.request :url_encoded
				end

				res = fctx.post do |req|
					req.url url
					req.headers['X-Casper-API-Key'] = @api_key
					req.headers['User-Agent'] = 'Masqueraide/'+VERSION
					req.body = 'jwt='+params["jwt"]
				end
				if res.status != 200
					case res.status
					when 400
						raise "BadRequestException: " + JSON.parse(res.body)["message"]
					when 429
						raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
					end
				end
				return res
			end

			# Send POST data to a URL.
			def post(url, params={})
				fctx = Faraday.new(:url => ENDPOINT) do |f|
					f.adapter Faraday.default_adapter
					f.response :logger
					f.request :url_encoded
				end

				res = fctx.post do |req|
					req.url url
					req.headers['X-Casper-API-Key'] = @api_key
					req.headers['User-Agent'] = 'Masqueraide/'+VERSION
					req.body = 'jwt='+params["jwt"]
				end
				if res.status != 200
					case res.status
					when 400
						raise "BadRequestException: " + JSON.parse(res.body)["message"]
					when 429
						raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
					end
				end
				return res
			end

			# Send GET to a URL.
			def get(url, params={})
				fctx = Faraday.new(:url => ENDPOINT) do |f|
					f.adapter Faraday.default_adapter
					f.response :logger
					f.request :url_encoded
				end
				res = fctx.get do |req|
					req.url url
					req.headers['X-Casper-API-Key'] = @api_key
					req.headers['User-Agent'] = 'Masqueraide/'+VERSION
				end
				if res.status != 200
					case res.status
					when 400
						raise "BadRequestException: " + JSON.parse(res.body)["message"]
					when 429
						raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
					end
				end
				return res
			end
		end
		end
	end
end