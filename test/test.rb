require "helper"
require "omniauth-pro-sante-connect"

class StrategyTest < StrategyTestCase
  include OAuth2StrategyTests
end

class ClientTest < StrategyTestCase
  test "has correct pro santé connect site" do
    assert_equal "https://auth.esw.esante.gouv.fr", strategy.client.site
  end

  test "has correct authorize url" do
    assert_equal "https://wallet.esw.esante.gouv.fr/auth", strategy.client.options[:authorize_url]
  end

  test "has correct token url" do
    assert_equal "/auth/realms/esante-wallet/protocol/openid-connect/token", strategy.client.options[:token_url]
  end
end

class CallbackUrlTest < StrategyTestCase
  test "returns the default callback url" do
    url_base = "http://auth.request.com"
    @request.stubs(:url).returns("#{url_base}/some/page")
    strategy.stubs(:script_name).returns("") # as not to depend on Rack env
    assert_equal "#{url_base}/auth/pro-sante-connect/callback", strategy.callback_url
  end

  test "returns path from callback_path option" do
    @options = { :callback_path => "/auth/pro-sante-connect/done"}
    url_base = "http://auth.request.com"
    @request.stubs(:url).returns("#{url_base}/page/path")
    strategy.stubs(:script_name).returns("") # as not to depend on Rack env
    assert_equal "#{url_base}/auth/pro-sante-connect/done", strategy.callback_url
  end
end

class UidTest < StrategyTestCase
  def setup
    super
    strategy.stubs(:identity).returns("user" => {"id" => "U123"}, "team" => {"id" => "T456"})
  end

  test "returns the user ID from user_identity" do
    assert_equal "U123-T456", strategy.uid
  end
end

class CredentialsTest < StrategyTestCase
  def setup
    super
    @access_token = stub("OAuth2::AccessToken")
    @access_token.stubs(:token)
    @access_token.stubs(:expires?)
    @access_token.stubs(:expires_at)
    @access_token.stubs(:refresh_token)
    strategy.stubs(:access_token).returns(@access_token)
  end

  test "returns a Hash" do
    assert_kind_of Hash, strategy.credentials
  end

  test "returns the token" do
    @access_token.stubs(:token).returns("123")
    assert_equal "123", strategy.credentials["token"]
  end

  test "returns the expiry status" do
    @access_token.stubs(:expires?).returns(true)
    assert strategy.credentials["expires"]

    @access_token.stubs(:expires?).returns(false)
    refute strategy.credentials["expires"]
  end

  test "returns the refresh token and expiry time when expiring" do
    ten_mins_from_now = (Time.now + 600).to_i
    @access_token.stubs(:expires?).returns(true)
    @access_token.stubs(:refresh_token).returns("321")
    @access_token.stubs(:expires_at).returns(ten_mins_from_now)
    assert_equal "321", strategy.credentials["refresh_token"]
    assert_equal ten_mins_from_now, strategy.credentials["expires_at"]
  end

  test "does not return the refresh token when test is nil and expiring" do
    @access_token.stubs(:expires?).returns(true)
    @access_token.stubs(:refresh_token).returns(nil)
    assert_nil strategy.credentials["refresh_token"]
    refute_has_key "refresh_token", strategy.credentials
  end

  test "does not return the refresh token when not expiring" do
    @access_token.stubs(:expires?).returns(false)
    @access_token.stubs(:refresh_token).returns("XXX")
    assert_nil strategy.credentials["refresh_token"]
    refute_has_key "refresh_token", strategy.credentials
  end
end

class UserInfoTest < StrategyTestCase

  def setup
    super
    @access_token = stub("OAuth2::AccessToken")
    strategy.stubs(:access_token).returns(@access_token)
  end

  test "performs a GET to '/auth/realms/esante-wallet/protocol/openid-connect/userinfo'" do
    @access_token.expects(:get).with('/auth/realms/esante-wallet/protocol/openid-connect/userinfo')
      .returns(stub_everything("OAuth2::Response"))
    strategy.identity
  end
end

class SkipInfoTest < StrategyTestCase

  test 'info should not include extended info when skip_info is specified' do
    @options = { skip_info: true }
    strategy.stubs(:identity).returns({})
    assert_equal %w[name email image team_name], strategy.info.keys.map(&:to_s)
  end

end

class NonceCheckTest < StrategyTestCase
  def setup
    super
    url_base = 'http://auth.request.com'
    @request.stubs(:url).returns("#{url_base}/some/page")
    @options = { provider_ignores_state: true }
  end

  test 'nonce is verified at callback' do
    @request.stubs(:params).returns({ 'nonce' => 'generated_by_me' })
    OmniAuth::Strategies::OAuth2.any_instance.stubs(:callback_phase).returns(true)
    strategy.expects(:fail!).never
    strategy.authorize_params
    strategy.callback_phase
  end

  test 'fails if nonce does not match' do
    OmniAuth::Strategies::OAuth2.any_instance.stubs(:callback_phase).returns(true)
    strategy
      .expects(:fail!)
      .with(
        :invalid_nonce,
        OmniAuth::Strategies::OAuth2::CallbackError.new(
          :invalid_nonce,
          'Nonce found in id token is invalid'))
      .once
    strategy.authorize_params
    @request.stubs(:params).returns({ 'nonce' => 'generated_by_me' })
    strategy.callback_phase
  end
end