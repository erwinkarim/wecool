class CreateMediasetPhotos < ActiveRecord::Migration
  def change
    create_table :mediaset_photos do |t|
      t.references :Photo
      t.references :Mediaset
      t.integer :order

      t.timestamps
    end
    add_index :mediaset_photos, :Photo_id
    add_index :mediaset_photos, :Mediaset_id
  end
end
