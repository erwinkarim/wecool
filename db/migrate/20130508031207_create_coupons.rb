class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.references :persona
      t.date :redeem_date
      t.date :expire_date

      t.timestamps
    end
    add_index :coupons, :persona_id
  end
end
