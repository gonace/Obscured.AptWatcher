require_relative 'setup'

describe Obscured::AptWatcher::Plugins do
  before(:context) {
    Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::RayGun)
  }

  context 'register' do
    it 'should register at least one service' do
      expect(Obscured::AptWatcher::Plugins.all.count).to be > 0
    end
  end

  context 'unregister' do
    before(:each) {
      Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::Bitbucket)
    }

    it 'should return nil for a unregister manager' do
      Obscured::AptWatcher::Plugins.unregister(Obscured::AptWatcher::Plugins::Bitbucket)
      expect(Obscured::AptWatcher::Plugins.get(:bitbucket)).to be_nil
    end
  end

  context 'get' do
    it 'should return for existing method' do
      expect(Obscured::AptWatcher::Plugins.get(:raygun)).to be_instance_of(Obscured::AptWatcher::Plugins::RayGun)
    end
    it 'should return nil for non-existing method' do
      expect(Obscured::AptWatcher::Plugins.get(:foo)).to be_nil
      expect(Obscured::AptWatcher::Plugins.get(:bar)).to be_nil
    end
  end

  context 'update' do
    let(:manager) { Obscured::AptWatcher::Plugins.get(:github) }

    before(:context) {
      Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::GitHub)
    }

    before(:each) {
      manager.install({enabled: false, key: "72540c03043246599640a49469cf3954", secret: "password"})
    }

    it 'should return the configuration on which it was installed' do
      expect(manager.config.properties[:enabled]).to eq(false)
      expect(manager.config.properties[:key]).to eq("72540c03043246599640a49469cf3954")
      expect(manager.config.properties[:secret]).to eq("password")
    end

    context 'updated' do
      before(:each) {
        manager.update({enabled: true, key: "41e3a443aa1644d68f31e804ef4621db", secret: "YrG4DTV672dqXUa2"})
      }

      it 'should return true when installed' do
        expect(manager.config.properties[:enabled]).to eq(true)
        expect(manager.config.properties[:key]).to eq("41e3a443aa1644d68f31e804ef4621db")
        expect(manager.config.properties[:secret]).to eq("YrG4DTV672dqXUa2")
      end
    end
  end

  context 'install' do
    let(:manager) { Obscured::AptWatcher::Plugins.get(:raygun) }

    before(:each) {
      manager.install({enabled: false})
    }

    it 'should return a manager that is not enabled when installed but not enabled' do
      expect(manager.enabled?).to be(false)
    end

    context 'enabled' do
      before(:each) {
        manager.uninstall
        manager.install({enabled: true})
      }

      it 'should return a manager that is enabled when installed and enabled' do
        expect(manager.enabled?).to be(true)
      end
    end
  end


  context 'call' do
    it 'should return for existing method' do
      expect(Obscured::AptWatcher::Plugins.call(:raygun, :type)).to eq(:plugin)
    end
    it 'should raise error for non-existing method' do
      expect{Obscured::AptWatcher::Plugins.call(:raygun, :method)}.to raise_error(ArgumentError)
    end
  end
end