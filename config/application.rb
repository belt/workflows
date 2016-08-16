# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

# require 'rails/all'

require 'active_model/railtie'
require 'action_controller/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workflows
  # project configuration
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.middleware.delete 'ActionDispatch::Static'
    config.middleware.delete 'ActionDispatch::Reloader'
    config.middleware.delete 'Rack::Lock'
    # config.middleware.delete 'Rack::ETag'
    # config.middleware.delete 'Rack::ConditionalGet'

    # config.cache_store = :memory_store, { size: 64.megabytes }

    # Configure autoload paths to load in stuff in the lib directory and subdirs
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.sequel.load_database_tasks = :sequel
    config.sequel.skip_connect = false

    config.sequel.after_connect = proc do
      Sequel::Model.plugin :force_encoding, 'UTF-8'

      Sequel::Model.plugin :timestamps, update_on_create: true
      Sequel::Model.plugin :active_model
      Sequel::Model.plugin :boolean_readers
      Sequel::Model.plugin :defaults_setter

      Sequel::Model.plugin :table_select
      Sequel::Model.plugin :update_or_create
      Sequel::Model.plugin :validation_helpers
      Sequel::Model.plugin :validate_associated

      Sequel::Model.plugin :prepared_statements
      Sequel::Model.plugin :prepared_statements_safe
      Sequel::Model.plugin :prepared_statements_associations
      Sequel::Model.plugin :prepared_statements_with_pk

      Sequel::Model.plugin :string_stripper
    end
  end
end
