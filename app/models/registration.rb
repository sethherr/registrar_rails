class Registration < ApplicationRecord
  STATUS_ENUM = {
    registered: 0,
    for_sale: 1,
    missing: 2
  }.freeze

  enum status: STATUS_ENUM

  has_many :
end
