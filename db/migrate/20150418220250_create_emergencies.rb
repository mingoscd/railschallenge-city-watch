class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.string :code
      t.index :code
      t.integer :fire_severity, :police_severity, :medical_severity
      t.boolean :served
      t.datetime :resolved_at
      t.timestamps null: false
    end
  end
end
