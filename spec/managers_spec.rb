require_relative 'setup'

describe Obscured::AptWatcher::Managers do
  before(:context) {
    Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::APT)
  }

  context 'register' do
    it 'should register at least one manager' do
      expect(Obscured::AptWatcher::Managers.all.count).to be > 0
    end
  end

  context 'unregister' do
    before(:each) {
      Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::YUM)
    }

    it 'should return nil for a unregister manager' do
      Obscured::AptWatcher::Managers.unregister(Obscured::AptWatcher::Managers::YUM)
      expect(Obscured::AptWatcher::Managers.get(:yum)).to be_nil
    end
  end

  context 'get' do
    it 'should return for existing manager' do
      expect(Obscured::AptWatcher::Managers.get(:apt)).to be_instance_of(Obscured::AptWatcher::Managers::APT)
    end
    it 'should return nil for non-existing manager' do
      expect(Obscured::AptWatcher::Managers.get(:foo)).to be_nil
      expect(Obscured::AptWatcher::Managers.get(:bar)).to be_nil
    end
  end

  context 'update' do
    let(:manager) { Obscured::AptWatcher::Managers.get(:rpm) }

    before(:context) {
      Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::RPM)
    }

    before(:each) {
      manager.install({enabled: false, username: "username", password: "password"})
    }

    it 'should return the configuration on which it was installed' do
      expect(manager.config.properties[:enabled]).to eq(false)
      expect(manager.config.properties[:username]).to eq("username")
      expect(manager.config.properties[:password]).to eq("password")
    end

    context 'updated' do
      before(:each) {
        manager.update({enabled: true, username: "john", password: "YrG4DTV672dqXUa2"})
      }

      it 'should return true when installed' do
        expect(manager.config.properties[:enabled]).to eq(true)
        expect(manager.config.properties[:username]).to eq("john")
        expect(manager.config.properties[:password]).to eq("YrG4DTV672dqXUa2")
      end
    end
  end

  context 'install' do
    let(:manager) { Obscured::AptWatcher::Managers.get(:apt) }

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
    it 'should return for existing manager' do
      expect(Obscured::AptWatcher::Managers.call(:apt, :type)).to eq(:manager)
    end
    it 'should raise error for non-existing manager' do
      expect{Obscured::AptWatcher::Managers.call(:apt, :method)}.to raise_error(ArgumentError)
    end
  end
end