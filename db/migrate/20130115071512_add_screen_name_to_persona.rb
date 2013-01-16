class AddScreenNameToPersona < ActiveRecord::Migration
  def change
    add_column :personas, :screen_name, :string
  end
end
