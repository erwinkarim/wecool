class AddFeaturedFlagToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :featured, :boolean, :null => false, :default=> false
  end
end
