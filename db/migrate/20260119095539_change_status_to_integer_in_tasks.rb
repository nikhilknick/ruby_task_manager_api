class ChangeStatusToIntegerInTasks < ActiveRecord::Migration[8.1]
  def up
    remove_column :tasks, :status, :string
    add_column :tasks, :status, :integer, default: 0, null: false
  end

  def down
    remove_column :tasks, :status, :integer
    add_column :tasks, :status, :string
  end
end
