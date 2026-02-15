class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :ticker
      t.float :buy_price
      t.float :quantity
      t.float :sell_price
      t.integer :status
      t.timestamp :buyed_at
      t.timestamp :selled_at

      t.timestamps
    end
  end
end
