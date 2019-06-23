FactoryBot.define do
  factory :gateway, :class => Obscured::AptWatcher::Models::Gateway do
    name { 'Gateway Sweden' }
    hostname { 'sweden.domain.tld' }
    username { 'username' }
    password { 'password123' }
  end
end