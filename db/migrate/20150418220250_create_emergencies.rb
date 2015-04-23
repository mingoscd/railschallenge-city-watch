class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.timestamps null: false
    end
  end
end
