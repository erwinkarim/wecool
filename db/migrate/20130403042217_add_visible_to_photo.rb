class AddVisibleToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :visible, :boolean, :null => false, :default => true
  end
end
