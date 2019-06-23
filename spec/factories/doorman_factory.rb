FactoryBot.define do
  factory :user, :class => Obscured::Doorman::User do
    username { 'homer.simpson@obscured.se' }
    password { 'password123' }
    first_name { 'Homer' }
    last_name { 'Simpson' }
  end
end