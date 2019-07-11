# frozen_string_literal: true

require_relative '../setup'

describe Obscured::AptWatcher::Models::Configuration do
  let!(:properties) do
    {
      type: :application,
      signature: :global,
      properties: {
        a: 'A',
        b: :b,
        c: [1, 2, 3]
      }
    }
  end

  before(:each) do
    Obscured::AptWatcher::Models::Configuration.delete_all
  end

  context 'make' do
    let!(:cfg) { Obscured::AptWatcher::Models::Configuration.make(properties) }

    it 'returns an unsaved document' do
      expect(cfg).to_not be_nil
      expect(cfg.persisted?).to be(false)
    end
  end

  context 'make!' do
    let!(:cfg) { Obscured::AptWatcher::Models::Configuration.make!(properties) }

    context 'without tags' do
      it 'returns an unsaved document' do
        expect(cfg).to_not be_nil
        expect(cfg.persisted?).to be(true)
      end
    end
  end
end
