FactoryBot.define do
  factory :user, :class => Obscured::Doorman::User do
    username {'homer.simpson@obscured.se'}

    before(:create) do |user, evaluator|
      user.set_password 'foo/bar'
      user.set_name 'Homer', 'Simpson'
    end
  end
end