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
    it 'should return nil for a unregister manager' do
      #Obscured::AptWatcher::Managers.unregister(Obscured::AptWatcher::Managers::APT)
      #expect(Obscured::AptWatcher::Managers.get(:apt)).to be_nil
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
    it 'should return false when called installed? since it is only loaded' do
      expect(Obscured::AptWatcher::Managers.get(:apt).installed?).to be(false)
    end
  end

  context 'update' do
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