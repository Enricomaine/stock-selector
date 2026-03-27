class AddCategoryTypeToRankings < ActiveRecord::Migration[8.0]
  def change
    add_column :rankings, :category_type, :integer
  end
end
