# Omniauth::ProSanteConnect

This Gem contains the PRO Santé Connect strategy for OmniAuth.

## Before You Begin

You should have already installed OmniAuth into your app; if not, read the [OmniAuth README](https://github.com/omniauth/omniauth) to get started.

## Using This Strategy

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-pro-sante-connect', github: 'doctolib/omniauth-pro-sante-connect'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pro_sante_connect, 'CLIENT_ID', 'SECRET'
end
```

Replace `'CLIENT_ID'` and `'SECRET'` with the appropriate values.

If you are using [Devise](https://github.com/plataformatec/devise) then it will look like this:

```ruby
Devise.setup do |config|
  config.omniauth :pro_sante_connect, 'CLIENT_ID', 'SECRET'
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
