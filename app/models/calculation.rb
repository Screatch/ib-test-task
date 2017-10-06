# frozen_string_literal: true

class Calculation < ApplicationRecord
  MAX_WEEKS = 250

  attribute :weeks_to_wait, :integer, default: 25
  belongs_to :user

  validates :base_amount, presence: true, numericality: true
  validates :base_currency, inclusion: { in: ExchangeRate::AVAILABLE_CURRENCIES }, presence: true
  validates :target_currency, inclusion: { in: ExchangeRate::AVAILABLE_CURRENCIES }, presence: true
  validate :base_and_target_currency_not_same

  validates :weeks_to_wait, numericality: { less_than_or_equal_to: Calculation::MAX_WEEKS, only_integer: true, greater_than_or_equal_to: 10 }
  validates :wait_until, inclusion: { in: (Date.today..Date.today + Calculation::MAX_WEEKS.weeks) }

  before_validation :set_wait_until

  private

    def set_wait_until
      self.wait_until = Date.current + weeks_to_wait.to_i.weeks if wait_until.blank?
    end

    def base_and_target_currency_not_same
      errors.add(:target_currency, "can't be the same as base currency") if base_currency == target_currency
    end
end
