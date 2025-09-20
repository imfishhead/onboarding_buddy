class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type
      t.string :title
      t.text :description
      t.string :emoji
      t.string :level

      t.timestamps
    end
  end
end
