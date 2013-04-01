class RenameTrackersToFollowers < ActiveRecord::Migration
  def up
    rename_table :trackers, :followers
  end

  def down
    rename_table :followers, :trackers
  end
end
