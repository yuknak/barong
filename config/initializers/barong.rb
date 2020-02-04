# frozen_string_literal: true


# 1/ check if ENV key exist then validate and set
# 2/ if no check in credentials then validate and set
# 3/ if no generate display warning, raise error in production, and set

require 'barong/app'
require 'barong/keystore'

begin
  private_key_path = ENV['JWT_PRIVATE_KEY_PATH']

  if !private_key_path.nil?
    pkey = Barong::KeyStore.open!(private_key_path)
    Rails.logger.info('Loading private key from: ' + private_key_path)

  elsif Rails.application.credentials.has?(:private_key)
    pkey = Barong::KeyStore.read!(Rails.application.credentials.private_key)
    Rails.logger.info('Loading private key from credentials.yml.enc')

  elsif !Rails.env.production?
    #pkey = Barong::KeyStore.generate
    #Rails.logger.warn('Warning !! Generating private key')
    Rails.logger.warn('Warning !! Using test private key')
    pkey = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAxcFCteyZ0w+KORQo88yaM20YIDFLLbPMOeZLRzmIBsgW/18l\nyZFKbuFfcL1O2c4y93Ag5xCwIrrsrZIOmEudsw1Cbu+hR4JnROS8nWgYxgExC/KJ\noeZi0N5+WNAjvOBxPdovk0W+z20FCecD964qAtVmXc7W1NuVX4CbWv/7IljHk3zX\n464ZThTrCBKuEfjLsK3I7aPbtSf4xFT90Mmn/poJaekjfXUGHH997OEvDdE0SvxT\ntBg1jq6OnrxhMUBvPrN6ccCV67xOOBT+rKyx5Zzgxa68m2CoIhCOMjQAlRB4Svu2\nOW8eb+FlgFlS4VOeRm6NICB0hHyPH1hLn8OvewIDAQABAoIBAHzxmTOWVK4skFl1\n6lX3PKonUGnumyA6DFu8rG1I5S/bteQNerN7D7s0u/dgNHSaukrp1nAHdDHNRoJ3\n2K7Sf8XEJ+gtkQm8U4EMwDr3rUdVM2boC5t2E5MCMHPutdW9PO8mbo6vL1qg9+EE\ny9XufW6i4/V7HPMJ9buMZxu8xjAxKMDr2ssWD/fR7i53AFEw6LjfcWKzrjTuoJMa\nvcquyymbkNGw+1bTs/rjZNMGgb874FIEiJsGa80lzri7CaE89W22qrt0bs/b0n9m\npOeIFp3QQ7FrWl6040oYt72XyIKbcScuFNd7FEi1pmZYPQh5xWTTPOvWEE3hy9Jk\npFuX6MkCgYEA7o86t7KIPE1eFuMgM3EuBTeRpBBnOAqwXWuvjSSUdLweyqF8+kU1\nGO7KCVDUZBnAd5QjXxuZjO4E0CNDoTh1m/bElwGopyaJG6b+ombSOD6K8KV9lM8s\nLVMPl86mHFqkHeHcSx6WWC4cENzGGqMkRAEJaKA1L+jDlF7EVKssMKUCgYEA1DZa\nASMzdVW5fkwmQ+Yu84uJ/lvHzWzSfjjXY7FkLqa22sQ7YwijRlVJfE93Bb0MpBJD\nZW34nck9zdlH2zEa9YpYZY+RVl6BFsmKBXTqNXW9ixfCPf+vca7sLYQ+hpdlfGE5\n53mv8Lax+odUT2ReloQhqW4G4NjqqG/X+VpRRZ8CgYAcoCMzl8CxO7dml6ptgc87\n4Qcg4LcCCoZPL3TJQvJtb4ViWy5b+aH9c+naZFCYEl79+lCkQPOT7Zu2PgUHe3bh\nWCMO26wZIo6hOtCjPCNNjHOvnKwNBy8N4UGlva5BCL9YtplwiiMQQbgsbdF3sMvR\nPS6b112Keiu9ygFVB5Ut4QKBgDXtMeYEGfmBNUgA9eBfSCMfnIuEqztqofrtWt68\nn2azetgQ8b5y3XrsBWaPkwFkTygKdBH8ZidCknAS/Q2YZu9qnpgAacB293rg8C/+\ny92V8/q6qOO0a9MJzn6qknEFXAbFdj96Ttlus7+kUCp0qQy6uwshKKJOvSLceRem\neeylAoGBANcbaYE/pErX3ZxL5RLDA6GhdcSO3DJHEjNOxgxApE/Pd0POMtfD4fiG\nHNTSRU8FWP9xkUJ/v37pe8jnGg1tb5qYf9IJuiC5TxWYnwuhuyLdprm82FAcaVKr\nS5a22NlfRn3A4D4uZQ9ilRMV61YvXGofspZjugC54oL3zEWfcdU5\n-----END RSA PRIVATE KEY-----\n"
  else
    raise Barong::KeyStore::Fatal
  end
rescue Barong::KeyStore::Fatal
  Rails.logger.fatal('Private key is invalid')
  raise 'FATAL: Private key is invalid'
end

kstore = Barong::KeyStore.new(pkey)

Barong::App.define do |config|
  # General configuration ---------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#general-configuration

  config.set(:app_name, 'Barong')
  config.set(:domain, 'openware.com')
  config.set(:uid_prefix, 'ID', regex: /^[A-z]{2,6}$/)
  config.set(:session_name, '_barong_session')
  config.set(:session_expire_time, '1800', type: :integer)
  config.set(:required_docs_expire, 'true', type: :bool)
  config.set(:doc_num_limit, '10', type: :integer)
  config.set(:geoip_lang, 'en', values: %w[en de es fr ja ru])
  config.set(:csrf_protection, 'true', type: :bool)

  # CAPTCHA configuration ---------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#captcha-configuration
  config.set(:captcha, 'none', values: %w[none recaptcha geetest])
  config.set(:geetest_id, '')
  config.set(:geetest_key, '')
  config.set(:recaptcha_site_key, '')
  config.set(:recaptcha_secret_key, '')

  # Dependencies configuration (vault, redis, rabbitmq) ---------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#dependencies-configuration-vault-redis-rabbitmq
  config.set(:event_api_rabbitmq_host, 'localhost')
  config.set(:event_api_rabbitmq_port, '5672')
  config.set(:event_api_rabbitmq_username, 'guest')
  config.set(:event_api_rabbitmq_password, 'guest')
  config.set(:vault_address, 'http://localhost:8200')
  config.set(:vault_token, 'changeme')
  config.set(:redis_url, 'redis://localhost:6379/1')

  # CORS configuration  -----------------------------------------------
  config.set(:api_cors_origins, '*')
  config.set(:api_cors_max_age, '3600')
  config.set(:api_cors_allow_credentials, 'false', type: :bool)

  # Config files configuration ----------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#config-files-configuration
  config.set(:config, 'config/barong.yml', type: :path)
  config.set(:maxminddb_path, '', type: :path)
  config.set(:seeds_file, Rails.root.join('config', 'seeds.yml'), type: :path)
  config.set(:authz_rules_file, Rails.root.join('config', 'authz_rules.yml'), type: :path)
end

Barong::GeoIP.lang = Barong::App.config.geoip_lang

Rails.application.config.x.keystore = kstore
Barong::App.config.keystore = kstore
