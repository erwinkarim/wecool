class AddAvatarToPersona < ActiveRecord::Migration
  def change
    add_column :personas, :avatar, :string
  end
end
