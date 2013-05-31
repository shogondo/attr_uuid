require "rubygems"
require "bundler/setup"
require "simplecov"

SimpleCov.start do
  add_filter "spec"
  add_filter "vendor"
end

$: << File.join(File.dirname(__FILE__), "..", "lib")

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
