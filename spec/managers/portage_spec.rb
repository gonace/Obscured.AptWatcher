require_relative '../setup'

describe Obscured::AptWatcher::Managers::Portage do
  let!(:manager) { Obscured::AptWatcher::Managers::Portage.new }
  let!(:template) {
    {
      enabled: { type: "checkbox", placeholder: "", value: true }
    }
  }

  it 'should return correct name' do
    expect(manager.name).to eq("Portage")
  end
  it 'should return correct template' do
    expect(manager.template).to eq(template)
  end
  it 'should return correct type' do
    expect(manager.type).to eq(:manager)
  end
  it 'should return correct version' do
    expect(manager.version).to eq("0.0.1")
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