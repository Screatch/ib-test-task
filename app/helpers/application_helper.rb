module ApplicationHelper
  def format_currency(number, currency)
    number_to_currency(number, unit: currency, format: "%n %u")
  end
end
