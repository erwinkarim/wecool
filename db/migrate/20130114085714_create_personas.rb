class CreatePersonas < ActiveRecord::Migration
  def change
    create_table :personas do |t|
      t.string :realname

      t.timestamps
    end
  end
end
