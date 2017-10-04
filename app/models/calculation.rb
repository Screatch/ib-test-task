class Calculation < ApplicationRecord
  validate :base_and_target_currency_not_same

  # before_validation :calculate_amount

  def after_save

  end

  def base_and_target_currency_not_same
    errors.add(:target_currency, "can't be the same as base currency") if base_currency == target_currency
  end
end
