class AddBasePriceToSku < ActiveRecord::Migration
  def change
    add_column :skus, :base_price, :decimal
  end
end
