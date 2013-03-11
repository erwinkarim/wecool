class AddFeaturedToMediaset < ActiveRecord::Migration
  def change
    add_column :mediasets, :featured, :boolean, :null => false, :default => false
  end
end
