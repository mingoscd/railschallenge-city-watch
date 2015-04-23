class AddAssignedTo < ActiveRecord::Migration
  def up
    add_column :responders, :assigned, :string
  end

  def down
    remove_column :responders, :assigned, :string
  end
end
