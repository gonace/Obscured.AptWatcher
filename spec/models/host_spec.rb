require_relative '../setup'

describe Obscured::AptWatcher::Models::Host do
  let!(:properties) {
    {
      name: "DNS Stockholm",
      hostname: "10.0.0.1",
      username: "username",
      password: "password",
      manager: :apt,
      tags: "Stockholm,Sweden"
    }
  }

  before(:each) {
    Obscured::AptWatcher::Models::Host.delete_all
  }

  context 'make' do
    let!(:host) { Obscured::AptWatcher::Models::Host.make(properties.except(:tags).merge(hostname: "10.0.0.2")) }

    it 'returns an unsaved document' do
      expect(host).to_not be_nil
      expect(host.password).to eq(properties[:password])
      expect(host.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:host) { Obscured::AptWatcher::Models::Host.make!(properties.except(:tags)) }

    context 'without tags' do
      it 'returns an unsaved document' do
        expect(host).to_not be_nil
        expect(host.password).to eq(properties[:password])
        expect(host.persisted?).to be(true)
      end
    end

    context 'with tags' do
      before(:each) {
        properties[:tags].split(",").each do |name|
          tag = Obscured::AptWatcher::Models::Tag.upsert!({ name: name, type: :default})
          host.add_tag(tag)
        end
      }

      it 'returns document with tags' do
        expect(host.tags).to_not be(nil)
        expect(host.tags.first.name).to eq('Stockholm')
        expect(host.tags.last.name).to eq('Sweden')
      end
    end
  end
end