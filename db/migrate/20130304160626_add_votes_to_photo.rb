class AddVotesToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :up_votes, :integer, :null => false, :default => 0
    add_column :photos, :down_votes, :integer, :null => false, :default => 0
  end
end
