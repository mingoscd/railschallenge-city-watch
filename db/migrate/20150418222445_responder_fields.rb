class ResponderFields < ActiveRecord::Migration
  def change
    add_column :responders, :emergency_code, :string
    add_column :responders, :type, :string
    add_column :responders, :name, :string
    add_column :responders, :capacity, :integer
    add_column :responders, :on_duty, :boolean, default: false
  end
end
