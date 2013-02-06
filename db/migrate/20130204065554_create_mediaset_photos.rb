class CreateMediasetPhotos < ActiveRecord::Migration
  def change
    create_table :mediaset_photos do |t|
      t.references :photo
      t.references :mediaset
      t.integer :order

      t.timestamps
    end
    add_index :mediaset_photos, :photo_id
    add_index :mediaset_photos, :mediaset_id
  end
end
