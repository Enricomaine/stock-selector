class Transaction < ApplicationRecord
  enum :status, { open: 1, closed: 2 }
end
