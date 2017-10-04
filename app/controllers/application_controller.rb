class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def get_exchange_rate(rate_info)
    base_rate = (ExchangeRate::BASE_CURRENCY == rate_info['base_currency']) ? 1 : rate_info['base_rate']
    target_rate = (ExchangeRate::BASE_CURRENCY == rate_info['target_currency']) ? 1 : rate_info['target_rate']

    return target_rate.to_f / base_rate.to_f
  end

end
