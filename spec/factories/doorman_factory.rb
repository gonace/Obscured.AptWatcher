FactoryBot.define do
  factory :user, class: Obscured::Doorman::User do
    username { 'homer.simpson@obscured.se' }
    password { BCrypt::Password.create('Password123') }
    first_name { 'Homer' }
    last_name { 'Simpson' }
    mobile { '+467855568' }
    role { :admin }
  end
end