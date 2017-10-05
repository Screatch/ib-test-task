# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    password = "totallysecureandvalidpassword"

    sequence(:id)
    sequence :email do |n|
      "squid#{n}@squid.com"
    end
    password password
    password_confirmation password
  end
end
