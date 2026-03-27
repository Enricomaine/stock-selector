class AddCategoryTypeToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :category_type, :integer
  end
end
