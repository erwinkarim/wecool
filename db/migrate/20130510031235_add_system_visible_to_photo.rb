class AddSystemVisibleToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :system_visible, :boolean, :default => false
  end
end
