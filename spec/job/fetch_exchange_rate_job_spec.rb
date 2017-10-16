# frozen_string_literal: true

require "spec_helper"

describe FetchExchangeRateJob do
  it "processes the job and records to database" do
    FetchExchangeRateJob.perform_now("2017-10-05")

    exchange_rates = ExchangeRate.where(created_at: Date.parse("2017-10-05"))

    expect(exchange_rates.size).to eq 1
    expect(exchange_rates[0].rate_data.count).to eq ExchangeRate::AVAILABLE_CURRENCIES.size - 1 # minus base currency

    exchange_rates[0].rate_data.each do |rate_data|
      expect(ExchangeRate::AVAILABLE_CURRENCIES).to include rate_data[0]
      expect(rate_data[1]).to be_a Float
    end
  end

  # Negative scenario
  it "doesn't have the exchange rate for the weekend" do
    old_exchange_rate_count = ExchangeRate.count
    FetchExchangeRateJob.perform_now("2017-10-15")

    expect(ExchangeRate.count).to eq old_exchange_rate_count
  end

  it "duplicate exchange rate should not be saved" do
    old_exchange_rate_count = ExchangeRate.count
    FetchExchangeRateJob.perform_now("2017-10-05")

    expect(ExchangeRate.count).to eq old_exchange_rate_count
  end
end
