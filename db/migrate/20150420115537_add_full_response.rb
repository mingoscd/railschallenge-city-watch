class AddFullResponse < ActiveRecord::Migration
  def up
    add_column :emergencies, :served, :boolean
  end

  def down
    remove_column :emergencies, :served, :boolean
  end
end
