class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.string :emergency_code, :type, :name, :assigned
      t.index :name
      t.integer :capacity
      t.boolean :on_duty, default: false
      t.timestamps null: false
    end
  end
end
