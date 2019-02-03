# frozen_string_literal: true

module MoneyFormattable
  extend ActiveSupport::Concern

  # Stub currency to USD, because that's all we care about for now
  def currency
    "USD"
  end

  def money_formatted(amnt)
    Money.new(amnt || 0, currency).format
  end
end
