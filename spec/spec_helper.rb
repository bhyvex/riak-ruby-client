$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    if ENV['COVERAGE_SUITE']
      SimpleCov.command_name ENV['COVERAGE_SUITE']
    end
    add_filter 'vendor/'
  end

end

require 'rubygems' # Use the gems path only for the spec suite
require 'riak'
require 'rspec'
require 'stringio'
require 'pp'

# Only the tests should really get away with this.
Riak.disable_list_keys_warnings = true

%w[integration_setup
   version_filter
   wait_until
   search_corpus_setup
   unified_backend_examples
   test_client
   search_config
   crdt_search_config
   crdt_search_fixtures
].each do |file|
  require File.join("support", file)
end

RSpec.configure do |config|
  #config.debug = true
  config.mock_with :rspec

  config.before(:each) do
    Riak::RObject.on_conflict_hooks.clear
  end

  if TestClient.test_client_configuration[:authentication]
    config.filter_run_excluding no_security: true
  else
    config.filter_run_excluding yes_security: true
  end

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  if defined?(::Java)
    config.seed = Time.now.utc
  else
    config.order = :random
  end

  config.raise_errors_for_deprecations!

  begin
    require 'instrumentable'
  rescue LoadError => e
    config.filter_run_excluding instrumentation: true
  end
end
