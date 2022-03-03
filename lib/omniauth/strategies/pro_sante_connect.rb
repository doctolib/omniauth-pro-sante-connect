require 'omniauth/strategies/oauth2'
require 'uri'
require 'rack/utils'

module OmniAuth
  module Strategies
    class ProSanteConnect < OmniAuth::Strategies::OAuth2

      option :name, 'pro-sante-connect'
      option :authorize_options, [:scope, :acr_values, :response_type]
      option :client_options, {
        site: 'https://auth.esw.esante.gouv.fr',
        token_url: '/auth/realms/esante-wallet/protocol/openid-connect/token',
        authorize_url: 'https://wallet.esw.esante.gouv.fr/auth',
      }
      option :send_nonce, true

      info do
        access_token.get('/auth/realms/esante-wallet/protocol/openid-connect/userinfo').parsed
      end

      def authorize_params
        add_nonce if options.send_nonce
        params = super.merge(required_options)
        persist_nonce if options.send_nonce

        params
      end

      def callback_url
        full_host + script_name + callback_path # Do not include query string
      end

      def callback_phase
        verify_nonce! if options.send_nonce
        super
      end

      def required_options
        {
          scope: 'openid scope_all',
          acr_values: 'eidas2',
          response_type: 'code',
        }
      end

      def add_nonce
        options.authorize_params[:nonce] = request.params['nonce'] || SecureRandom.hex(24)
      end

      def persist_nonce
        session['omniauth.nonce'] = options.authorize_params[:nonce]
      end

      def verify_nonce!
        return if request.params['nonce'] == session.delete('omniauth.nonce')

        fail! :invalid_nonce, CallbackError.new(:invalid_nonce, 'Nonce found in id token is invalid')
      end
    end
  end
end
