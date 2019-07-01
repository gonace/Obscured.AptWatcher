FactoryBot.define do
  factory :host, class: Obscured::AptWatcher::Models::Host do
    name { 'PHP Server #12' }
    hostname { 'php12.domain.tld' }
    username { 'username' }
    password { 'password123' }
    manager { :apt }
    location { { latitude: 40.703056, longitude: -74.026667 } }

    pending { 0 }
    installed { 0 }
  end
end