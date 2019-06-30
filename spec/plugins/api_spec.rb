require_relative '../setup'

describe Obscured::AptWatcher::Plugins::API do
  let!(:plugin) { Obscured::AptWatcher::Plugins::API.new }
  let!(:template) {
    {
      enabled: { type: "checkbox", placeholder: "", value: true },
      username: { type: "text", placeholder: "", value: true },
      password: { type: "password", placeholder: "", value: true }
    }
  }

  it 'should return correct name' do
    expect(plugin.name).to eq("API")
  end
  it 'should return correct template' do
    expect(plugin.template).to eq(template)
  end
  it 'should return correct type' do
    expect(plugin.type).to eq(:integration)
  end
  it 'should return correct version' do
    expect(plugin.version).to eq("0.0.1")
  end
  it 'should return enabled as false' do
    expect(plugin.enabled?).to eq(false)
  end
  it 'should return installed as false' do
    expect(plugin.installed?).to eq(false)
  end

  context 'config' do
    it 'should return config as nil' do
      expect(plugin.config).to be_nil
    end
  end
end