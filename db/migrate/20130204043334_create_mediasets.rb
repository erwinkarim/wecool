class CreateMediasets < ActiveRecord::Migration
  def change
    create_table :mediasets do |t|
      t.string :title
      t.text :description
      t.references :persona

      t.timestamps
    end
    add_index :mediasets, :persona_id
  end
end
