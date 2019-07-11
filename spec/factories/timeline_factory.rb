# frozen_string_literal: true

FactoryBot.define do
  factory :event, class: Mongoid::Timeline::Record do
    type { :comment }
    message { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }
    producer { 'homer.simpson@obscured.se' }
    proprietor { {} }


    trait :as_comment do
      type { :comment }
    end

    trait :as_change do
      type { :change }
    end

    trait :with_account do
      proprietor { { account_id: BSON::ObjectId.new } }
    end
  end
end
