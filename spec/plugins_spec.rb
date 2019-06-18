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

  context 'get' do
    it 'should return for existing method' do
      expect(Obscured::AptWatcher::Plugins.get(:raygun)).to be_instance_of(Obscured::AptWatcher::Plugins::RayGun)
    end
    it 'should return nil for non-existing method' do
      expect(Obscured::AptWatcher::Plugins.get(:foo)).to be_nil
      expect(Obscured::AptWatcher::Plugins.get(:bar)).to be_nil
    end
    it 'should return false when called installed? since it is only loaded' do
      expect(Obscured::AptWatcher::Plugins.get(:raygun).installed?).to be(false)
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