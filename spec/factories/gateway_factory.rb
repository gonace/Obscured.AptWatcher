FactoryBot.define do
  factory :gateway, class: Obscured::AptWatcher::Models::Gateway do
    name { 'Gateway Sweden' }
    hostname { 'sweden.domain.tld' }
    username { 'username' }
    password { 'password123' }
    location { { latitude: 40.703056, longitude: -74.026667 } }
  end
end