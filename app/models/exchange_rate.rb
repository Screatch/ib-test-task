# frozen_string_literal: true

class ExchangeRate < ApplicationRecord
  BASE_CURRENCY = "EUR".freeze
  AVAILABLE_CURRENCIES = %w(AUD BGN BRL CAD CHF CNY CZK DKK EUR GBP HKD HRK HUF IDR ILS INR).freeze

  validates_uniqueness_of :created_at
end
