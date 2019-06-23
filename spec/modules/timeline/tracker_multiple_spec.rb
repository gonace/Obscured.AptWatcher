require_relative '../../../lib/modules/timeline'
require_relative '../../setup'


describe Mongoid::Timeline::Tracker do
  let!(:account_email) { 'aptwatcher@obscured.se' }
  let!(:message) { 'Praesent a massa dui. Etiam eget purus consequat, mollis erat et, rhoncus tortor.' }
  let!(:user) { FactoryBot.create(:user) }
  let!(:gateway) { FactoryBot.create(:gateway) }

  describe 'write event' do
    context 'validates that that events is written to correct collection' do
      let!(:user_event) { user.add_event({ type: :comment, message: message, producer: user.email }) }
      let!(:gateway_event) { gateway.add_event({ type: :change, message: message, producer: user.email }) }

      context 'for user' do
        it { expect(user_event.type).to eq(:comment) }
        it { expect(user_event.message).to eq(message) }
        it { expect(user_event.proprietor).to eq({ user_id: user.id.to_s }) }

        context 'get event' do
          let!(:event) { user.add_event({ type: :comment, message: message, producer: user.email }) }
          let!(:response) { user.get_event(event.id.to_s) }

          it { expect(response.id.to_s).to eq(event.id.to_s) }
          it { expect(response.type).to eq(event.type) }
          it { expect(response.message).to eq(event.message) }
        end

        context 'get events' do
          let!(:response) { user.get_events }

          it { expect(response.length).to eq(1) }
        end

        context 'find events' do
          let!(:event) { user.add_event({ type: :comment, message: message, producer: user.email }) }
          let!(:event2) { user.add_event({ type: :foobar, message: message, producer: user.email }) }
          let!(:event3) { user.add_event({ type: :foobar, message: message, producer: user.email }) }
          let!(:response) { user.find_events({ type: :foobar }, { }) }

          it { expect(response.length).to eq(2) }
        end

        context 'search events' do
          before(:each) {
            (1..10).each do
              user.add_event({ type: :comment, message: message, producer: user.email })
            end
          }

          let!(:event) { user.add_event({ type: :comment, message: message, producer: user.email }) }
          let!(:event2) { user.add_event({ type: :comment, message: message, producer: user.email }) }
          let!(:response) { user.search_events(user.email, { limit: 5 }) }

          it { expect(response.length).to eq(5) }
        end
      end

      context 'for gateway' do
        it { expect(gateway_event.type).to eq(:change) }
        it { expect(gateway_event.message).to eq(message) }
        it { expect(gateway_event.proprietor).to eq({ gateway_id: gateway.id.to_s }) }

        context 'get event' do
          let!(:event) { gateway.add_event({ type: :comment, message: message, producer: gateway.id.to_s }) }
          let!(:response) { gateway.get_event(event.id.to_s) }

          it { expect(response.id.to_s).to eq(event.id.to_s) }
          it { expect(response.type).to eq(event.type) }
          it { expect(response.message).to eq(event.message) }
        end

        context 'get events' do
          let!(:response) { gateway.get_events }

          it { expect(response.length).to eq(1) }
        end

        context 'find events' do
          let!(:event) { gateway.add_event({ type: :comment, message: message, producer: gateway.id.to_s }) }
          let!(:event2) { gateway.add_event({ type: :foobar, message: message, producer: gateway.id.to_s }) }
          let!(:event3) { gateway.add_event({ type: :foobar, message: message, producer: gateway.id.to_s }) }
          let!(:response) { user.find_events({ type: :comment }, { limit: 1 }) }

          it { expect(response.length).to eq(1) }
        end

        context 'search events' do
          before(:each) {
            (1..10).each do
              gateway.add_event({ type: :comment, message: message, producer: gateway.id.to_s })
            end
          }
          let!(:response) { gateway.search_events(gateway.id.to_s, { limit: 5 }) }

          it { expect(response.length).to eq(5) }
        end
      end
    end
  end
end