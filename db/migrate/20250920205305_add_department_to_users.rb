class AddDepartmentToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :department, :integer, default: 0
  end
end
