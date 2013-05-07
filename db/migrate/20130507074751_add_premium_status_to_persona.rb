class AddPremiumStatusToPersona < ActiveRecord::Migration
  def change
    add_column :personas, :premium, :boolean, :null => false, :default => false
    add_column :personas, :premiumSince, :date
    add_column :personas, :premiumExpire, :date
  end
end
