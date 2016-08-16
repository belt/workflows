# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the integration environment the application's code is not reloaded on
  # every request. This environment is one part "production" and one part "development"
  # It runs as if it were production with respect to eager loading, caching,
  # etc... but enables logging, shows full error reports, doesn't compress assets, etc.
  config.cache_classes = true

  # Eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  if defined? Bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.rails_logger = false
      Bullet.bullet_logger = true
      Bullet.raise = false
    end
  end

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  # :debug, :info, :warn, :error, :fatal, and :unknown
  config.log_level = :warn

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
end
