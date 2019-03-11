$LOAD_PATH.unshift File.dirname(__FILE__)
require 'factory_bot'
require 'rspec'
require 'timecop'

FactoryBot.find_definitions


RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.before(:each) do
  end
end