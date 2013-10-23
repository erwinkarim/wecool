class AddBasePriceToSku < ActiveRecord::Migration
  def change
    add_column :skus, :base_price, :number
  end
end
