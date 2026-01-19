class AddDefaultsAndIndexesToTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tasks, :priority, 0
    add_index :tasks, :status
    add_index :tasks, :priority
  end
end
