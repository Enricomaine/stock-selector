json.extract! transaction, :id, :ticker, :buy_price, :quantity, :sell_price, :status, :buyed_at, :selled_at, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
