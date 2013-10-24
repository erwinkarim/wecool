class AddOrderIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :order_id, :integer
		add_index :carts, :order_id
  end
end
