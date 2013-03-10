class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.references :persona
      t.string :tracked_object_type
      t.integer :tracked_object_id
      t.string :relationship

      t.timestamps
    end
    add_index :trackers, :persona_id
  end
end
