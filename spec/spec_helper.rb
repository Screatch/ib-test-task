# frozen_string_literal: true

# require 'simplecov'
# SimpleCov.coverage_dir 'tmp/coverage'
# SimpleCov.start
# SimpleCov.start "rails" do
#   add_group "API", "app/api"
#   add_group "Payments", "app/payments"
#   add_group "Filters", "app/filters"
#   add_group "Drops", "app/drops"
# end
#
# ENV["RAILS_ENV"] ||= "test"
#
# require File.expand_path("../../config/environment", __FILE__)
# require "rspec/rails"
#
# Dir[Rails.root.join("spec/config/**/*.rb")].each { |f| require f }
#
# Dir[Rails.root.join("spec/support/*.rb")].each { |f| require f }

require "rails_helper"
require "rspec-rails"
require "database_cleaner"
require "capybara/rails"

Capybara.run_server = true
Capybara.app_host = "http://localhost:3002"
Capybara.server_port = 3002

FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), "factories")
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL

  config.formatter = :documentation
  Capybara.javascript_driver = :webkit

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Database cleaner
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end
end

DatabaseCleaner.strategy = :truncation
