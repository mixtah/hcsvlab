HcsvlabWeb::Application.configure do

# This will set the default host not just for action_mailer and action_controller, but for anything using the url_helpers
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'

  config.galaxy_url = 'http://localhost:8080/root'

  # Base directory where user contributed annotations will be stored
  config.user_annotations_location = "/data/contributed_annotations/"

  # Base directory where api created collections will be stored
  config.api_collections_location = "#{Rails.root}/test/api/collections"

  # Temporary directory where imports/zip files will be uploaded
  config.upload_location = "#{Rails.root}/test/api/uploads"

  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  config.assets.debug = true
  config.assets.enabled = true

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end

