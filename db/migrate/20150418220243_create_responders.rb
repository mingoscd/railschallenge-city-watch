class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.timestamps null: false
    end
  end
end
