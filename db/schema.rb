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

ActiveRecord::Schema[8.1].define(version: 2026_06_25_184511) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.text "details"
    t.bigint "organization_id", null: false
    t.bigint "trackable_id", null: false
    t.string "trackable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_activity_logs_on_organization_id"
    t.index ["trackable_type", "trackable_id"], name: "index_activity_logs_on_trackable"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "checklist_items", force: :cascade do |t|
    t.boolean "completed"
    t.string "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_checklist_items_on_task_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.bigint "organization_id", null: false
    t.integer "role"
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "key_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 10, scale: 2, default: "0.0"
    t.text "description"
    t.bigint "objective_id", null: false
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.decimal "target_value", precision: 10, scale: 2
    t.string "title", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["objective_id"], name: "index_key_results_on_objective_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "okr_cycle_id", null: false
    t.bigint "owner_id"
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["okr_cycle_id"], name: "index_objectives_on_okr_cycle_id"
    t.index ["owner_id"], name: "index_objectives_on_owner_id"
  end

  create_table "okr_cycles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "organization_id", null: false
    t.date "start_date"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_okr_cycles_on_organization_id"
  end

  create_table "organization_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "role"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "allow_auto_join"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.boolean "archived", default: false
    t.bigint "assignee_id"
    t.string "color", default: "#6366f1"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "icon", default: "folder"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.integer "priority", default: 0
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_projects_on_assignee_id"
    t.index ["organization_id"], name: "index_projects_on_organization_id"
  end

  create_table "strategic_canvases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "goal"
    t.text "metrics"
    t.text "next_steps"
    t.text "problem"
    t.bigint "project_id", null: false
    t.text "resources"
    t.text "risks"
    t.text "roadmap"
    t.text "stakeholders"
    t.text "team"
    t.datetime "updated_at", null: false
    t.text "value_proposition"
    t.index ["project_id"], name: "index_strategic_canvases_on_project_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "position", default: 0
    t.integer "priority", default: 0
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.bigint "project_id", null: false
    t.integer "status", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activity_logs", "organizations"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "checklist_items", "tasks"
  add_foreign_key "comments", "tasks"
  add_foreign_key "comments", "users"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users"
  add_foreign_key "key_results", "objectives"
  add_foreign_key "objectives", "okr_cycles"
  add_foreign_key "objectives", "users", column: "owner_id"
  add_foreign_key "okr_cycles", "organizations"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "projects", "organizations"
  add_foreign_key "projects", "users", column: "assignee_id"
  add_foreign_key "strategic_canvases", "projects"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users", column: "assignee_id"
end
