class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :persona
      t.string :spreedly_token_id
      t.integer :status

      t.timestamps
    end
    add_index :orders, :persona_id
  end
end
