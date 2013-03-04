class AddVoterToPersona < ActiveRecord::Migration
  def change
    add_column :personas, :up_votes, :integer, :null => false, :default => 0
    add_column :personas, :down_votes, :integer, :null => false, :default => 0
  end
end
