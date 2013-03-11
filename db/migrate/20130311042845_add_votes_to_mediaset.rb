class AddVotesToMediaset < ActiveRecord::Migration
  def change
    add_column :mediasets, :up_votes, :integer, :null => false, :default => 0
    add_column :mediasets, :down_votes, :integer, :null => false, :default => 0
  end
end
