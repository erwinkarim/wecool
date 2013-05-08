class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :item_type
      t.string :item_sku
      t.integer :item_id
      t.references :persona

      t.timestamps
    end
    add_index :carts, :persona_id
  end
end
