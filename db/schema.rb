# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_20_133100) do
  create_table "happiness_wallets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "current_points"
    t.integer "lifetime_points"
    t.integer "level"
    t.float "multiplier"
    t.datetime "last_calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_happiness_wallets_on_user_id"
  end

  create_table "llm_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "channel"
    t.integer "purpose"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_llm_sessions_on_user_id"
  end

  create_table "mood_checkins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "score"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_mood_checkins_on_user_id"
  end

  create_table "onboarding_tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "required"
    t.integer "order_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_assignments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "onboarding_task_id", null: false
    t.integer "status"
    t.date "due_date"
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_task_id"], name: "index_task_assignments_on_onboarding_task_id"
    t.index ["user_id"], name: "index_task_assignments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "happiness_wallets", "users"
  add_foreign_key "llm_sessions", "users"
  add_foreign_key "mood_checkins", "users"
  add_foreign_key "task_assignments", "onboarding_tasks"
  add_foreign_key "task_assignments", "users"
end
