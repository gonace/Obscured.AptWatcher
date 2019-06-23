# encoding: utf-8
require_relative '../../lib/modules/timeline/record'

FactoryBot.define do
  factory :event, class: Mongoid::Timeline::Record do
    type { :comment }
    message { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }
    producer { 'info@adeprimo.se' }
    proprietor { Hash.new }


    trait :as_comment do
      type { :comment }
    end

    trait :as_change do
      type { :change }
    end

    trait :with_account do
      proprietor { { :account_id => BSON::ObjectId.new } }
    end
  end
end