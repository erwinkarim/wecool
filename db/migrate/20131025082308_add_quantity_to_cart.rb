class AddQuantityToCart < ActiveRecord::Migration
  def change
    add_column :carts, :quantity, :integer, :null => false, :default => 1
  end
end
