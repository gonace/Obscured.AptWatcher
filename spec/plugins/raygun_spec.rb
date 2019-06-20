require_relative '../setup'

describe Obscured::AptWatcher::Plugins::RayGun do
  let!(:plugin) { Obscured::AptWatcher::Plugins::RayGun.new }
  let!(:template) {
    {
      enabled: { type: "checkbox", placeholder: "", value: true },
      key: { type: "text", placeholder: "", value: "" }
    }
  }

  it 'should return correct name' do
    expect(plugin.name).to eq("RayGun")
  end
  it 'should return correct template' do
    expect(plugin.template).to eq(template)
  end
  it 'should return correct type' do
    expect(plugin.type).to eq(:plugin)
  end
  it 'should return correct version' do
    expect(plugin.version).to eq("0.0.1")
  end
  #it 'should return enabled as false' do
  #  expect(plugin.enabled?).to eq(false)
  #end
  #it 'should return installed as false' do
  #  expect(plugin.installed?).to eq(false)
  #end

  #context 'config' do
  #  it 'should return config as nil' do
  #    expect(plugin.config).to be_nil
  #  end
  #end
end