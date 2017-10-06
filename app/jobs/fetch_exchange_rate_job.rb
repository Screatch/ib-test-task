# frozen_string_literal: true

class FetchExchangeRateJob < ApplicationJob
  queue_as :default

  def perform(date)
    date = (date) ? Date.parse(date) : Date.current

    # There are no currency rates on weekends so we can cut that
    return true if %w(Sat Sun).include?(date.strftime("%a"))

    formatted_date = date.strftime("%F")
    response = JSON.parse(RestClient.get("http://api.fixer.io/#{formatted_date}"))

    # Means that we don't have yet data for that date (maybe bank didn't yet)
    return true if response["date"] != formatted_date

    # We save only these currencies that we are interested in
    rates = response["rates"].select { |currency| ExchangeRate::AVAILABLE_CURRENCIES.include?(currency) }

    ExchangeRate.create(rate_data: rates, created_at: date)
  end
end
