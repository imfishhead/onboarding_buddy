class CreateOnboardingTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :onboarding_tasks do |t|
      t.string :title
      t.text :description
      t.boolean :required
      t.integer :order_num

      t.timestamps
    end
  end
end
