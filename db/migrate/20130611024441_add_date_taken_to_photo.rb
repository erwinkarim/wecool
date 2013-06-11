class AddDateTakenToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :taken_at, :datetime
  end
end
