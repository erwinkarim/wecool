class AddPowersToSku < ActiveRecord::Migration
  def change
    add_column :skus, :power, :string
  end
end
