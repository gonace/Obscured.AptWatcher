# frozen_string_literal: true

require_relative '../setup'

describe Obscured::AptWatcher::Managers::Pacman do
  let!(:manager) { Obscured::AptWatcher::Managers::Pacman.new }
  let!(:template) do
    {
      enabled: { type: 'checkbox', placeholder: '', value: true }
    }
  end

  it 'should return correct name' do
    expect(manager.name).to eq('Pacman')
  end
  it 'should return correct template' do
    expect(manager.template).to eq(template)
  end
  it 'should return correct type' do
    expect(manager.type).to eq(:manager)
  end
  it 'should return correct version' do
    expect(manager.version).to eq('0.0.1')
  end
  it 'should return enabled as false' do
    expect(manager.enabled?).to eq(false)
  end
  it 'should return installed as false' do
    expect(manager.installed?).to eq(false)
  end

  context 'config' do
    it 'should return config as nil' do
      expect(manager.config).to be_nil
    end
  end
end
