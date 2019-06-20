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
    let!(:document) { Obscured::AptWatcher::Models::Gateway.make(properties.except(:tags).merge(hostname: "10.0.0.2")) }

    it 'returns an unsaved document' do
      expect(document).to_not be_nil
      expect(document.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:document) { Obscured::AptWatcher::Models::Gateway.make!(properties.except(:tags)) }

    context 'without tags' do
      it 'returns an unsaved document' do
        expect(document).to_not be_nil
        expect(document.persisted?).to be(true)
      end
    end

    context 'with tags' do
      before(:each) {
        properties[:tags].split(",").each do |name|
          tag = Obscured::AptWatcher::Models::Tag.upsert!({ name: name, type: :default})
          document.add_tag(tag)
        end
      }

      it 'returns document with tags' do
        expect(document.tags).to_not be(nil)
        expect(document.tags.first.name).to eq('Stockholm')
        expect(document.tags.last.name).to eq('Sweden')
      end
    end
  end
end