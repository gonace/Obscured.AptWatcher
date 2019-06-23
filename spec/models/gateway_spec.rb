require_relative '../setup'

describe Obscured::AptWatcher::Models::Gateway do
  let!(:properties) {
    {
      name: "Gateway Stockholm",
      hostname: "10.0.0.1",
      username: "username",
      password: "password",
      tags: "Stockholm,Sweden"
    }
  }

  before(:each) {
    Obscured::AptWatcher::Models::Gateway.delete_all
  }

  context 'make' do
    let!(:gateway) { Obscured::AptWatcher::Models::Gateway.make(properties.except(:tags).merge(hostname: "10.0.0.2")) }

    it 'returns an unsaved document' do
      expect(gateway).to_not be_nil
      expect(gateway.password).to eq(properties[:password])
      expect(gateway.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:gateway) { Obscured::AptWatcher::Models::Gateway.make!(properties.except(:tags)) }

    context 'without tags' do
      it 'returns an unsaved document' do
        expect(gateway).to_not be_nil
        expect(gateway.password).to eq(properties[:password])
        expect(gateway.persisted?).to be(true)
      end
    end

    context 'with tags' do
      before(:each) {
        properties[:tags].split(",").each do |name|
          tag = Obscured::AptWatcher::Models::Tag.upsert!({ name: name, type: :default})
          gateway.add_tag(tag)
        end
      }

      it 'returns document with tags' do
        expect(gateway.tags).to_not be(nil)
        expect(gateway.tags.first.name).to eq('Stockholm')
        expect(gateway.tags.last.name).to eq('Sweden')
      end
    end
  end
end