# The Snapchat Room for Masqueraide AI bots.

require 'faraday'
require 'uri'
require 'jwt'
require 'json'
require 'securerandom'
require 'openssl'

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
			SC_URL = "https://app.snapchat.com"

			attr_accessor :debug, :auth_token, :username

			# The Snapchat API, brought to you by @liamcottle of Casper.
			def initialize(api_key, api_secret, debug=false, proxy=nil)
				@api_key = api_key
				@api_secret = api_secret
				@username = nil
				@auth_token = nil
				@verify = true
				if debug == false
					@debug = false
				else
					@debug = true
				end
				if proxy.nil? == false
					@proxy = proxy
					@verify = false
				end
			end

			# Device ID.
			def device_id()
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/device_id",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				json_data = post_sc_request(response)
				return json_data
			end

			# Snapchat updates.
			def updates()
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/all_updates",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				json_data = post_sc_request(response)
				return json_data
			end

			# IP routing.
			def ip_routing()
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/bq/ip_routing",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				json_data = post_sc_request(response)
				return json_data
			end

			# Snapchat stories.
			def stories()
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/bq/stories",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				json_data = post_sc_request(response)
				return json_data
			end

			# Snapchat conversations.
			def conversations()
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/conversations",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				json_data = post_sc_request(response)
				return json_data
			end

			# A Snapchat conversation,
			def conversation(username)
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/conversation",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				sc_data = {
					"conversation_id" => @username + "~" + username
				}
				json_data = post_sc_request(response, sc_data)
				return json_data
			end

			# Chat Typing...
			def chat_typing(*usernames)
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/bq/chat_typing",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				sc_data = {
					"recipient_usernames" => "#{usernames}"
				}
				json_data = post_sc_request(response, sc_data)
				return json_data
			end

			# Send a chat message.
			def convo_info(message, username)
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end

				# Conversation post messages.
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/conversation_post_messages",
				}

				jwt = sign_token(params)
				response = endpoint_auth(jwt)

				# Get convo auth token.
				msg_auth = conversation_auth(username)
				payload = msg_auth['messaging_auth']['payload']
				mac = msg_auth['messaging_auth']['mac']
				id = gen_chat_uuid
				
				message_data = [{
					"presences" => [
						@username => true,
						"to" => false,
					],
					"receiving_video" => false,
					"supports_here" => false,
					"header" => [
						"auth" => [
							"mac" => mac,
							"payload" => payload,
						],
						"to" => [
							username
						],
						"conv_id" => @username + "~" + username,
						"from" => @username, 
						"conn_sequence_number" => 0
					],
					"retried" => false,
					"id" => id,
					"type" => "presence"
				}]

				message_data <<  {
					"presences" => [
						@username => true,
						"to" => false,
					],
					"receiving_video" => false,
					"supports_here" => false,
					"header" => [
						"auth" => [
							"mac" => mac,
							"payload" => payload,
						],
						"to" => [
							username
						],
						"conv_id" => username + "~" +  @username,
						"from" => @username, 
						"conn_sequence_number" => 0
					],
					"retried" => false,
					"id" => id,
					"type" => "presence"
				}

				# Get timestamp.
				ts = JSON.parse(response.body)["endpoints"][0]["params"]["timestamp"]
				sc_data = {
					"recipient_usernames" => @username,
					"messages" => message_data.to_json,
					"timestamp" => ts
				}

				json_data = post_sc_request(response, sc_data)
				return json_data
			end

			# If you've already got an auth token,  
			# auth token needs the username and auth_token.
			def set_auth_token(username, auth_token)
				@username = username
				@auth_token = auth_token
			end

			# Login into Snapchat using Casper and fetch the url.
			def login(username, password)
				data = {
					"username" => username,
 					"password" => password
				}
				response = casper_login(username, password)
				json_data = post_sc_login_request(response)
				set_auth_token(username, json_data['updates_response']['auth_token'])
			end

			private

			# Low Level API Library for Snapchat API & Casper API.

			# Conversation authentication with two people.
			def conversation_auth(to)
				if @username.nil? == true and @username.nil? == true
					creds_not_found
				end
				params = {
					"username" => @username,
					"auth_token" => @auth_token,
					"endpoint" => "/loq/conversation_auth_token",
				}
				jwt = sign_token(params)
				response = endpoint_auth(jwt)
				sc_data = {
					"conversation_id" => [@username].push(to).join("~")
				}
				json_data = post_sc_request(response, sc_data)
				return json_data
			end
			# Casper Endpoint authentication.
			def endpoint_auth(jwt)
				casper_auth('/snapchat/ios/endpointauth', {"jwt" => jwt})
			end

			# Login into Casper.
			def casper_login(username, password)
				data = {
					"username" => username,
 					"password" => password
				}
				jwt = sign_token(data)
				res = casper_auth('/snapchat/ios/login', {"jwt" => jwt})
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

			# Forward Casper login request to Snapchat. (Casper -> Snapchat)
			def post_sc_login_request(cr)
				url = URI(cr["url"])
				headers = cr["headers"]
				params = cr["params"]
				sc_response = post(url.path, headers, params)
				sc_json_data = JSON.parse(sc_response.body)
			end

			# Forward Casper endpoint request to Snapchat. (Casper -> Snapchat)
			def post_sc_request(cr, sc_params={})
				casper_response = JSON.parse(cr.body)["endpoints"][0]
				url = casper_response["endpoint"]
				headers = casper_response["headers"]
				params = casper_response["params"]
				params.merge!(sc_params) unless sc_params.empty?
				sc_response = post(url, headers, params)
				if sc_response.body.length == 0
					return {}.to_json
				end
				sc_json_data = JSON.parse(sc_response.body)
			end

			# Authenticate the generated JWT token with the Casper API.
			# TODO: Better exceptions, return nil instead of rasiing exceptions.
			def casper_auth(url, params={})
				fctx = Faraday.new(:url => CASPER_ENDPOINT, :ssl => {:verify => @verify}) do |f|
					if @debug == true
						f.response :logger
					end
					if @proxy.nil? == false
						f.proxy(@proxy)
					end
					f.request :url_encoded
					f.adapter Faraday.default_adapter
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
						if res.headers['content-type'] == "application/json"
							raise "BadRequestException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 400 Bad Request"
						end
					when 404
						if res.headers['content-type'] == "application/json"
							raise "NotFoundError: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 404 Not Found"
						end
					when 429
						if res.headers['content-type'] == "application/json"
							raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 429 Rate Limit Reached"
						end
					end
				end
				return res
			end

			# Send POST data to a URL.
			# TODO: Better exceptions, return nil instead of rasiing exceptions.
			def post(url, headers, params={})
				fctx = Faraday.new(:url => SC_URL, :ssl => {:verify => @verify}) do |f|
					if @debug == true
						f.response :logger
					end
					if @proxy.nil? == false
						f.proxy(@proxy)
					end
					f.request :url_encoded
					f.adapter Faraday.default_adapter
				end
				res = fctx.post do |req|
					req.url url
					req.headers = headers
					req.body = params

					if @debug == true
						puts ""
						puts "REQUEST"
						puts ""
						puts req.body
						puts ""
					end
				end
				if @debug == true
					puts ""
					puts "RESPONSE"
					puts ""
					puts res.body
					puts ""
				end
				if res.status != 200
					case res.status
					when 400
						if res.headers['content-type'] == "application/json"
							raise "BadRequestException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 400 Bad Request"
						end
					when 404
						if res.headers['content-type'] == "application/json"
							raise "NotFoundError: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 404 Not Found"
						end
					when 429
						if res.headers['content-type'] == "application/json"
							raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 429 Rate Limit Reached"
						end
					end
				end
				return res
			end

			# Send GET to a URL.
			# TODO: Better exceptions, return nil instead of rasiing exceptions.
			def get(url, headers, params={})
				fctx = Faraday.new(:url => SC_URL, :ssl => {:verify => @verify}) do |f|
					if @debug == true
						f.response :logger
					end
					if @proxy.nil? == false
						f.proxy(@proxy)
					end
					f.request :url_encoded
					f.adapter Faraday.default_adapter
				end
				res = fctx.get do |req|
					req.url url
					req.headers = headers
					req.body = params
					if @debug == true
						puts ""
						puts "REQUEST"
						puts ""
						puts req.body
						puts ""
					end
				end
				if @debug == true
					puts ""
					puts "RESPONSE"
					puts ""
					puts res.body
					puts ""
				end
				if res.status != 200
					case res.status
					when 400
						if res.headers['content-type'] == "application/json"
							raise "BadRequestException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 400 Bad Request"
						end
					when 404
						if res.headers['content-type'] == "application/json"
							raise "NotFoundError: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 404 Not Found"
						end
					when 429
						if res.headers['content-type'] == "application/json"
							raise "RateLimitReachedException: " + JSON.parse(res.body)["message"]
						else
							puts res.body
							raise "Error: 429 Rate Limit Reached"
						end
					end
				end
				return res
			end

			# Generate a chat UUID.
			def gen_chat_uuid
				sr = SecureRandom.uuid()
				md5 = OpenSSL::Digest::MD5.new(sr).to_s
				uuid = ("%08s-%04s-%04x-%04x-%12s" % [md5[0..7], md5[8..11], md5[12..15].to_i(10), md5[16..19].to_i(10), md5[20..32]]).upcase
				return uuid
			end

			# Credentials not found method.
			def creds_not_found
				raise "CredentialsNotFoundError: " + "Please set an auth_token and a username to use this method."
			end
		end
		end
	end
end