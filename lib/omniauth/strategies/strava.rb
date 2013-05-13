require 'omniauth-oauth2'
require 'multi_json'

module OmniAuth
  module Strategies
    class Strava < OmniAuth::Strategies::OAuth2
      option :name, 'strava'
      option :client_options, {
        :site => 'https://strava.com/',
        :authorize_url => 'https://www.strava.com/oauth/authorize',
        :token_url => 'https://www.strava.com/oauth/token'
      }

      def authorize_params
        super.tap do |params|
          params[:approval_prompt] = 'force'
        end
      end

      def request_phase
        super
      end
      
      uid { access_token.token }

      info do
        {
          first_name: athlete['firstname'],
          last_name: athlete['lastname'],
          email: athlete['email'],
          strava_id: access_token.token
        }
      end

      def athlete
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :access_token
        @athlete ||= MultiJson.load(access_token.get('/api/v3/athlete', { access_token: access_token.token }).body)
      end

    end
  end
end