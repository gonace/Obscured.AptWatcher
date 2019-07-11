# frozen_string_literal: true

require_relative '../setup'
require_relative '../helpers/doorman'
require_relative '../helpers/warden'

describe Obscured::AptWatcher::Controllers::Host do
  include Helpers::Warden
  include Warden::Test::Helpers

  def app
    AppHelper.get(Obscured::AptWatcher::Controllers::Host)
  end

  let(:response) { last_response.body }
  let(:result) { response[:result] }
  let!(:user) { FactoryBot.create(:user) }

  before(:each) { login_as(user) }

  describe 'list' do
    it 'returns html' do
      get '/list'
      expect(last_response.status).to eq 200
    end
  end
end
