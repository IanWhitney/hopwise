class AddBatchNumberToRecipe < ActiveRecord::Migration
  def self.up
    add_column :recipes, :batch_number, :integer
  end

  def self.down
    remove_column :recipes, :batch_number
  end
end
