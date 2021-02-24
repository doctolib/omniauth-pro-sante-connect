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

      info do
        access_token.get('/auth/realms/esante-wallet/protocol/openid-connect/userinfo').parsed
      end

      def authorize_params
        super.merge(required_options)
      end

      def callback_url
        full_host + script_name + callback_path # Do not include query string
      end

      def required_options
        {
          scope: 'openid scope_all',
          acr_values: 'eidas2',
          response_type: 'code',
        }
      end
    end
  end
end
