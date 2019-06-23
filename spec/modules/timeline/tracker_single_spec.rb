require_relative '../../../lib/modules/timeline'
require_relative '../../setup'


describe Mongoid::Timeline::Tracker do
  let!(:type) { :comment }
  let!(:message) { 'Praesent a massa dui. Etiam eget purus consequat, mollis erat et, rhoncus tortor.' }
  let!(:user) { FactoryBot.create(:user) }

  describe 'event' do
    context 'add event' do
      let!(:event) { user.add_event({ type: type, message: message, producer: user.email }) }

      it { expect(event.type).to eq(type) }
      it { expect(event.message).to eq(message) }
      it { expect(event.proprietor).to eq({ user_id: user.id.to_s }) }
    end

    context 'get event' do
      let!(:event) { user.add_event({ type: type, message: message, producer: user.email }) }
      let(:response) { user.get_event(event.id.to_s) }

      it { expect(response.id.to_s).to eq(event.id.to_s) }
      it { expect(response.type).to eq(event.type) }
      it { expect(response.message).to eq(event.message) }
    end

    context 'get events' do
      let!(:event) { user.add_event({ type: type, message: message, producer: user.email }) }
      let!(:event2) { user.add_event({ type: type, message: message, producer: user.email }) }
      let(:response) { user.get_events }

      it { expect(response.length).to eq(2) }
    end

    context 'find events' do
      let(:response) { user.find_events({ type: :comment }, { }) }

      before(:each) {
        user.add_event({ type: :comment, message: message, producer: user.email })
        user.add_event({ type: :comment, message: message, producer: user.email })
        user.add_event({ type: :foobar, message: message, producer: user.email })
      }

      it { expect(response.length).to eq(2) }
    end

    context 'search events' do
      before(:each) {
        (1..5).each do
          user.add_event({ type: :payment, message: message, producer: user.email })
        end

        (1..10).each do
          user.add_event({ type: :comment, message: message, producer: user.email })
        end
      }

      context 'with limit' do
        let(:response) { user.search_events(user.email, { limit: 5 }) }

        it { expect(response.length).to eq(5) }
      end

      context 'with limit and type' do
        let(:response) { user.search_events(user.email, { limit: 10, type: :payment }) }

        #it { expect(response.length).to eq(5) }
      end
    end

    context 'edit event' do
      let!(:event) { user.add_event({ type: type, message: message, producer: user.email }) }

      context 'updates message for the event' do
        before(:each) do
          user.edit_event(event.id.to_s, { :message => "This is is a new message" })
        end

        it { expect(user.get_event(event.id.to_s).message).to eq("This is is a new message") }
      end
    end

    context 'delete event' do
      let!(:event) { user.add_event({ type: type, message: message, producer: user.email }) }

      context 'deletes the event' do
        before(:each) do
          user.delete_event(event.id.to_s)
        end

        it { expect(user.get_event(event.id.to_s)).to be_nil }
      end
    end
  end
end