require_relative '../../../lib/modules/timeline'
require_relative '../../setup'
require_relative 'helpers/user_service'


describe Mongoid::Timeline::Service::User do
  let!(:user) { FactoryBot.create(:user) }
  let!(:message) { 'Praesent a massa dui. Etiam eget purus consequat, mollis erat et, rhoncus tortor.' }
  let!(:service) { Mongoid::Timeline::Service::User.new }

  before(:each) {
    user.clear_events

    (1..2).each do
      user.add_event({ type: :event, message: message, producer: user.email })
    end
    (1..5).each do
      user.add_event({ type: :comment, message: message, producer: user.email })
    end
    (1..5).each do
      user.add_event({ type: :change, message: message, producer: user.email })
    end
  }

  describe 'all' do
    let(:response) { service.all }

    #it { expect(response.count).to eq(12) }
  end

  describe 'by' do
    context 'proprietor' do
      let(:response) { service.by({ proprietor: { user_id: user.id.to_s } }) }

      #it { expect(response.count).to eq(12) }
    end

    context 'type' do
      let(:response) { service.by({ type: :comment }) }

      #it { expect(response.count).to eq(5) }
    end

    context 'proprietor and type' do
      let(:response) { service.by({ type: :event, proprietor: { user_id: user.id.to_s } }) }

      #it 'debug' do
      #  pp response
      #  pp response.count
      #end
      #it { expect(response.count).to eq(2) }
    end
  end

  describe 'where' do
    context 'returns correct documents' do
      let(:response) { service.where({ type: :event }) }

      #it 'debug' do
      #  pp response
      #  pp response.count
      #end
      #it { expect(response.count).to eq(2) }
    end
  end

  describe 'delete' do
    context 'deletes document by id' do
      let!(:event) { user.add_event({ type: :change, message: message, producer: user.email }) }

      #it { expect(service.delete(event.id.to_s)).to eq(1) }
    end
  end
end