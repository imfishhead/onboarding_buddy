class RenameTypeToAchievementTypeInAchievements < ActiveRecord::Migration[8.0]
  def change
    rename_column :achievements, :type, :achievement_type
  end
end
