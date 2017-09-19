$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rspec'

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end


RSpec.shared_context 'with infinite precision', :infinite_precision do
  before do
  end

  after do
  end
end