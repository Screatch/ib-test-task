# frozen_string_literal: true

FactoryGirl.define do
  factory :calculation do
    sequence(:id)
    base_currency "EUR"
    base_amount 1500
    target_currency "CHF"
    wait_until Date.current + 25.weeks
  end
end
