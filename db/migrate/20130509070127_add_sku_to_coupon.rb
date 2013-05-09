class AddSkuToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :sku_id, :integer
    add_index :coupons, :sku_id
  end
end
