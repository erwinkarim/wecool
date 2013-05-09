class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.string :code
      t.string :model
      t.string :description

      t.timestamps
    end
  end
end
