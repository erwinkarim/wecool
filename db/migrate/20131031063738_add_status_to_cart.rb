class AddStatusToCart < ActiveRecord::Migration
  def change
    add_column :carts, :status, :integer, :null => false, :default => 0
  end
end
