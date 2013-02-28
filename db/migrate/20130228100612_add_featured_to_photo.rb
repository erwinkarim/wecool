class AddFeaturedToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :featured, :boolean
  end
end
