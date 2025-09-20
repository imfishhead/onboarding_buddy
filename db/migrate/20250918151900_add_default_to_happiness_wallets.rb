class AddDefaultToHappinessWallets < ActiveRecord::Migration[8.0]
  def change
    # 示例：新 migration
    change_column_default :happiness_wallets, :current_points, 0
    change_column_default :happiness_wallets, :lifetime_points, 0
    change_column_default :happiness_wallets, :level, 1
    change_column_default :happiness_wallets, :multiplier, 1.0
    add_index :happiness_transactions, [ :user_id, :occurred_at ]
  end
end
