FactoryBot.define do
  factory :tag, :class => Obscured::AptWatcher::Models::Tag do
    name { "Lorem Ipsum" }
    type { :package }
  end
end