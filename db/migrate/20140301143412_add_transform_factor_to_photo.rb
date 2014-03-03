class AddTransformFactorToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :transform_factor, :string
  end
end
