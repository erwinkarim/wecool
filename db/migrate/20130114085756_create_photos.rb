class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title
      t.text :description
      t.references :persona

      t.timestamps
    end
    add_index :photos, :persona_id
  end
end
