class EmergencyFields < ActiveRecord::Migration
  def change
    add_column :emergencies, :code, :string
    add_column :emergencies, :fire_severity, :integer
    add_column :emergencies, :police_severity, :integer
    add_column :emergencies, :medical_severity, :integer
    add_column :emergencies, :resolved_at, :datetime
  end
end
