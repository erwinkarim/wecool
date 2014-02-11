class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.references :persona
      t.integer :job_id

      t.timestamps
    end
    add_index :jobs, :persona_id
  end
end
