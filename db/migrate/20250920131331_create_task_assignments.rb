class CreateTaskAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :task_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :onboarding_task, null: false, foreign_key: true
      t.integer :status
      t.date :due_date
      t.datetime :assigned_at

      t.timestamps
    end
  end
end
