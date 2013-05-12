class AddSystemVisibleToMediaset < ActiveRecord::Migration
  def change
    add_column :mediasets, :system_visible, :boolean, :default => true
  end
end
