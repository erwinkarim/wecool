class AddAgreeTncToPersona < ActiveRecord::Migration
  def change
    add_column :personas, :agreeToTNC, :boolean
  end
end
