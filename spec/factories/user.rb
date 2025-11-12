
# frozen_string_literal: true

FactoryBot.define do
  # User objects are created from data passed from CAS.
  # The only field we get is uid. All user objects are given the
  # provider "cas"
  factory :user, class: User do
    provider { "cas" }
    sequence(:email) { |_n| "email-#{srand}@test.com" }
    sequence :uid do |n|
      "#{srand}#{n}"
    end
    password { "secret" }
  end
end