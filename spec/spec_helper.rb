require "rubygems"
require "bundler/setup"
require "simplecov"
require "with_model"

SimpleCov.start do
  add_filter "spec"
  add_filter "vendor"
end

$: << File.join(File.dirname(__FILE__), "..", "lib")

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.extend WithModel
end
