require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EvroneTest
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Europe/Moscow'
    config.active_record.default_timezone = :local

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = [:en, :ru]
    config.i18n.default_locale = :'ru'
    config.action_dispatch.default_headers = {}

    config.autoload_paths << Rails.root.join('app', 'policy')
    config.autoload_paths << Rails.root.join('app', 'form')

    config.before_configuration do
      env_file = Rails.root.join("config", 'keys.yml').to_s
      if File.exists?(env_file)
        YAML.load_file(env_file)[Rails.env].each do |key, value|
          ENV[key.to_s] = value
        end # end YAML.load_file
      end # end if File.exists?
    end # end config.before_configuration

    config.generators do |g|
      g.test_framework nil
      g.assets false
      g.helper false
      g.stylesheets false
    end
  end
end
