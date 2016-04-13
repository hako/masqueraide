# The Snapchat Room for Masqueraide AI bots.

# This Room provides functions for interacting with users on Snapchat.
# While you can send stories, pictures and get conversations, Chat functionality is currently not implemented.

require 'faraday'
require 'uri'
require 'jwt'
require 'json'
require 'securerandom'
require 'openssl'

module Masqueraide
  module Room
    # The Snapchat Room for Masqueraide AI bots.
    class Snapchat
      NAME = 'Snapchat'.freeze
      @@ais_in_room = []

      def initialize
      end

      # Set AI to the room.
      def ai=(ai)
        @ai = ai
        @@ais_in_room << @ai
      end

      # Fetch an AI from the room.
      def ai(name)
        ai = @@ais_in_room.select { |a| a.username == name }
        ai[0]
      end

      # The Snapchat API, brought to you by @liamcottle of Casper.
      class API
        CASPER_ENDPOINT = 'https://casper-api.herokuapp.com'.freeze
        SC_URL = 'https://app.snapchat.com'.freeze

        attr_accessor :debug, :auth_token, :username

        # Main initialisation of Snapchat room.
        def initialize(api_key, api_secret, debug = false, proxy = nil)
          @api_key = api_key
          @api_secret = api_secret
          @username = nil
          @auth_token = nil
          @verify = true
          @debug = if debug == false
                     false
                   else
                     true
                   end
          return if proxy.nil?
          @proxy = proxy
          @verify = false
        end
      end

      # Fetches the Device ID. Used for Push notifications.
      def device_id
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/loq/device_id'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        json_data = post_sc_request(response)
        json_data
      end

      # Fetches all Snapchat updates.
      def updates
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/loq/all_updates'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        json_data = post_sc_request(response)
        json_data
      end

      # IP routing stuff. Very boring.
      def ip_routing
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/bq/ip_routing'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        json_data = post_sc_request(response)
        json_data
      end

      # Upload profile picture. This changes a Snapchat profile picture.
      def upload_profile_pic(path)
        creds_not_found if @username.nil? == true && @username.nil? == true

        # Allow only .jpg or .jpeg. Check for it's existence too.
        raise 'InvalidFileFormatException' if (File.extname(path) != '.jpg') && (File.extname(path) != '.jpeg')
        raise Errno::ENOENT if File.exist?(path) == false
        data = Faraday::UploadIO.new(path, 'image/jpg')

        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/bq/upload_profile_data'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        sc_data = {
          'data' => data
        }
        json_data = post_sc_request(response, sc_data, true)
        json_data
      end

      # Fetches Snapchat stories.
      def stories
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/bq/stories'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        json_data = post_sc_request(response)
        json_data
      end

      # TODO: Upload a snap to a user or users.
      def send_snap(recipients, time = 5.0)
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/bq/send'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        sc_data = {
          'time' => time,
          'media_id' => (format '%s~%s', username, SecureRandom.uuid).upcase,
          'recipients' => recipients,
          'zipped' => 0
        }
        json_data = post_sc_request(response, sc_data)
        json_data
      end

      # Fetches an array of Snapchat conversations.
      def conversations
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/loq/conversations'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        json_data = post_sc_request(response)
        json_data
      end

      # Network Ping request. Again, boring.
      def network_ping_request
        headers = {
          'Host' => 'app.snapchat.com',
          'Accept-Locale' => 'en_GB',
          'Accept' => '*/*',
          'User-Agent' => 'Snapchat/9.27.5.0 (iPhone5,2; iOS 9.0.2)',
          'Accept-Language' => 'en-gb',
          'Connection' => 'keep-alive'
        }
        json_data = get('/bq/ping_network', headers)
        json_data
      end

      # Fetches a conversation authentication between two people.
      # Note: You must be both friends for this method to work.
      def conversation_auth(to)
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/loq/conversation_auth_token'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        sc_data = {
          'conversation_id' => [@username].push(to).sort.join('~')
        }
        json_data = post_sc_request(response, sc_data)
        json_data
      end

      # Fetches a single Snapchat conversation from username.
      def conversation(username)
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/loq/conversation'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        sc_data = {
          'conversation_id' => @username + '~' + username
        }
        json_data = post_sc_request(response, sc_data)
        json_data
      end

      # Send "Chat Typing..." to a username or usernames.
      def chat_typing(*usernames)
        creds_not_found if @username.nil? == true && @username.nil? == true
        params = {
          'username' => @username,
          'auth_token' => @auth_token,
          'endpoint' => '/bq/chat_typing'
        }
        jwt = sign_token(params)
        response = endpoint_auth(jwt)
        sc_data = {
          'recipient_usernames' => usernames.to_s
        }
        json_data = post_sc_request(response, sc_data)
        json_data
      end

      # TODO: Send a chat message. Currently not implemented.
      def chat(_message, _username)
        "Oh no! You're trying to call a function that is not implemented! Please use the official Snapchat app to chat instead. :P"
      end

      # If you've already got an auth token,
      # set_auth_token needs the username and valid auth_token.
      def set_auth_token(username, auth_token)
        @username = username
        @auth_token = auth_token
      end

      # Login into Snapchat using Casper and fetch the url.
      def login(username, password)
        response = casper_login(username, password)
        json_data = post_sc_login_request(response)
        set_auth_token(username, json_data['updates_response']['auth_token'])
      end

      private

      # The Low Level private API methods for the Snapchat API & Casper API.

      # Casper Endpoint authentication.
      def endpoint_auth(jwt)
        casper_auth('/snapchat/ios/endpointauth', 'jwt' => jwt)
      end

      # Login into Casper.
      def casper_login(username, password)
        data = {
          'username' => username,
          'password' => password
        }
        jwt = sign_token(data)
        res = casper_auth('/snapchat/ios/login', 'jwt' => jwt)
        JSON.parse(res.body)
      end

      # Sign the parameters with HS256 (HMAC-SHA256).
      def sign_token(params)
        time = Time.now.to_f.to_s
        data = { 'iat' => time }
        data.merge!(params) unless params.nil?
        token = JWT.encode data, @api_secret, 'HS256'
        token
      end

      # Forward Casper login request to Snapchat. (Casper -> Snapchat)
      def post_sc_login_request(cr)
        url = URI(cr['url'])
        headers = cr['headers']
        params = cr['params']
        sc_response = post(url.path, headers, params)
        JSON.parse(sc_response.body)
      end

      # Forward Casper endpoint request to Snapchat. (Casper -> Snapchat)
      def post_sc_request(cr, sc_params = {}, multipart = false)
        casper_response = JSON.parse(cr.body)['endpoints'][0]
        url = casper_response['endpoint']
        headers = casper_response['headers']
        params = casper_response['params']
        params.merge!(sc_params) unless sc_params.empty?
        sc_response = post(url, headers, params, multipart)
        return {}.to_json if sc_response.body.empty?
        JSON.parse(sc_response.body)
      end

      # Authenticate the generated JWT token with the Casper API.
      # TODO: Better exceptions, return nil instead of raising exceptions.
      def casper_auth(url, params = {})
        fctx = Faraday.new(url: CASPER_ENDPOINT, ssl: { verify: @verify }) do |f|
          f.response :logger if @debug == true
          f.proxy(@proxy) unless @proxy.nil?
          f.request :url_encoded
          f.adapter Faraday.default_adapter
        end

        res = fctx.post do |req|
          req.url url
          req.headers['X-Casper-API-Key'] = @api_key
          req.headers['User-Agent'] = 'Masqueraide/' + VERSION
          req.body = 'jwt=' + params['jwt']
        end
        if res.status != 200
          case res.status
          when 400
            if res.headers['content-type'] == 'application/json'
              raise 'BadRequestError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 400 Bad Request'
            end
          when 404
            if res.headers['content-type'] == 'application/json'
              raise 'NotFoundError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 404 Not Found'
            end
          when 429
            if res.headers['content-type'] == 'application/json'
              raise 'RateLimitReachedError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 429 Rate Limit Reached'
            end
          end
        end
        res
      end

      # Send POST data to a URL.
      # TODO: Better exceptions, return nil instead of raising exceptions.
      def post(url, headers, params = {}, multipart = false)
        fctx = Faraday.new(url: SC_URL, ssl: { verify: @verify }) do |f|
          f.response :logger if @debug == true
          f.proxy(@proxy) if @proxy.nil? == false
          if multipart == true
            f.request :multipart
          else
            f.request :url_encoded
          end
          f.adapter Faraday.default_adapter
        end

        # Check for multipart uploads
        res = ''
        if multipart == true
          res = fctx.post do |req|
            req.url url
            req.headers = headers
            req.options.boundary = 'Boundary+0xAbCdEfGbOuNdArY'
            req.headers['Content-Type'] = 'multipart/form-data'
            req.body = params
            if @debug == true
              puts ''
              puts 'REQUEST'
              puts ''
              puts req.body
              puts ''
            end
          end
        else
          res = fctx.post do |req|
            req.url url
            req.headers = headers
            req.body = params

            if @debug == true
              puts ''
              puts 'REQUEST'
              puts ''
              puts req.body
              puts ''
            end
          end
        end

        if @debug == true
          puts ''
          puts 'RESPONSE'
          puts ''
          puts res.body
          puts ''
        end

        if res.status != 200
          case res.status
          when 400
            if res.headers['content-type'] == 'application/json'
              raise 'BadRequestError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 400 Bad Request'
            end
          when 404
            if res.headers['content-type'] == 'application/json'
              raise 'NotFoundError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 404 Not Found'
            end
          when 503
            if res.headers['content-type'] == 'application/json'
              raise 'ServiceError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: Token Service is Unavailable'
            end
          when 429
            if res.headers['content-type'] == 'application/json'
              raise 'RateLimitReachedError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 429 Rate Limit Reached'
            end
          end
        end
        res
      end

      # Send GET to a URL.
      # TODO: Better exceptions, return nil instead of rasing exceptions.
      def get(url, headers, params = {}, _multipart = false)
        fctx = Faraday.new(url: SC_URL, ssl: { verify: @verify }) do |f|
          f.response :logger if @debug == true
          f.proxy(@proxy) if @proxy.nil? == false
          f.adapter Faraday.default_adapter
        end
        res = fctx.get do |req|
          req.url url
          req.headers = headers
          req.body = params
          if @debug == true
            puts ''
            puts 'REQUEST'
            puts ''
            puts req.body
            puts ''
          end
        end
        if @debug == true
          puts ''
          puts 'RESPONSE'
          puts ''
          puts res.body
          puts ''
        end
        if res.status != 200
          case res.status
          when 400
            if res.headers['content-type'] == 'application/json'
              raise 'BadRequestError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 400 Bad Request'
            end
          when 404
            if res.headers['content-type'] == 'application/json'
              raise 'NotFoundError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 404 Not Found'
            end
          when 503
            if res.headers['content-type'] == 'application/json'
              raise 'ServiceError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: Token Service is Unavailable'
            end
          when 429
            if res.headers['content-type'] == 'application/json'
              raise 'RateLimitReachedError: ' + JSON.parse(res.body)['message']
            else
              puts res.body
              raise 'Error: 429 Rate Limit Reached'
            end
          end
        end
        res
      end

      # Generate a chat UUID.
      def gen_chat_uuid
        SecureRandom.uuid
      end

      # Credentials not found method.
      def creds_not_found
        raise 'CredentialsNotFoundError: ' + 'Please set an auth_token and a username to use this method.'
      end
    end
  end
end
