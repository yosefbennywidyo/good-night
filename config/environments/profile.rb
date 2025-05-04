require "active_support/core_ext/integer/time"
require "active_support/core_ext/numeric/bytes"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Create a separate logger for Redis errors
  redis_logger = Logger.new("log/redis_profile.log", 10, 50.megabytes) # Keep 10 files, each 50MB max
  redis_logger.formatter = proc do |severity, timestamp, progname, msg|
    "[#{timestamp}] #{severity} #{progname}: #{msg}\n"
  end

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :redis_cache_store, {
    namespace: "good_night_profile", # Use a unique namespace for profile
    compress: true,               # Compress cached data
    expires_in: 1.day,            # Cache expiration period
    url: ENV.fetch("REDIS_URL_PROFILE", "redis://localhost:6379/1"),
    connect_timeout: 30,  # Seconds
    read_timeout: 0.2,   # Seconds
    write_timeout: 0.2,  # Seconds
    reconnect_attempts: 1,
    error_handler: ->(method:, returning:, exception:) {
      redis_logger.error("[Redis Error] Method: #{method}, Returning: #{returning}, Exception: #{exception.message}")
    },
    race_condition_ttl: 5.seconds,
    pool: {
      size: 5,
      timeout: 5
    }
  }

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  config.after_initialize do
    Prosopite.raise             = true
    Prosopite.rails_logger      = true
    Prosopite.prosopite_logger  = true
    Prosopite.stderr_logger     = true
  end

  Rails.application.routes.default_url_options[:host] = "localhost:3000"
end
