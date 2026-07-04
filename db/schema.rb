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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_141938) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.text "details"
    t.bigint "organization_id", null: false
    t.bigint "project_id"
    t.bigint "trackable_id", null: false
    t.string "trackable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_activity_logs_on_organization_id"
    t.index ["project_id"], name: "index_activity_logs_on_project_id"
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

  create_table "custom_field_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "custom_field_id", null: false
    t.bigint "customizable_id", null: false
    t.string "customizable_type", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["custom_field_id", "customizable_type", "customizable_id"], name: "idx_cfv_on_field_and_customizable", unique: true
    t.index ["custom_field_id"], name: "index_custom_field_values_on_custom_field_id"
    t.index ["customizable_type", "customizable_id"], name: "index_custom_field_values_on_customizable"
  end

  create_table "custom_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_type", default: "text", null: false
    t.string "name", null: false
    t.jsonb "options", default: []
    t.bigint "organization_id", null: false
    t.boolean "required", default: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_custom_fields_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_custom_fields_on_organization_id"
  end

  create_table "dashboard_widgets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.jsonb "settings", default: {}
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "visible", default: true, null: false
    t.string "widget_type", null: false
    t.integer "width", default: 1, null: false
    t.index ["user_id", "position"], name: "index_dashboard_widgets_on_user_id_and_position", unique: true
    t.index ["user_id"], name: "index_dashboard_widgets_on_user_id"
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

  create_table "kanban_columns", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.integer "position", default: 0, null: false
    t.bigint "project_id", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "position"], name: "index_kanban_columns_on_project_id_and_position"
    t.index ["project_id"], name: "index_kanban_columns_on_project_id"
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

  create_table "kpis", force: :cascade do |t|
    t.integer "category", default: 0
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2, default: "0.0"
    t.text "description"
    t.integer "frequency", default: 0
    t.jsonb "metadata", default: {}
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "owner_id"
    t.bigint "project_id"
    t.decimal "target_value", precision: 12, scale: 2
    t.integer "trend", default: 0
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_kpis_on_category"
    t.index ["frequency"], name: "index_kpis_on_frequency"
    t.index ["organization_id"], name: "index_kpis_on_organization_id"
    t.index ["owner_id"], name: "index_kpis_on_owner_id"
    t.index ["project_id"], name: "index_kpis_on_project_id"
  end

  create_table "matrix_cells", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "matrix_column_id", null: false
    t.bigint "matrix_row_id", null: false
    t.datetime "updated_at", null: false
    t.text "value", default: ""
    t.index ["matrix_column_id", "matrix_row_id"], name: "index_matrix_cells_on_matrix_column_id_and_matrix_row_id", unique: true
    t.index ["matrix_column_id"], name: "index_matrix_cells_on_matrix_column_id"
    t.index ["matrix_row_id"], name: "index_matrix_cells_on_matrix_row_id"
  end

  create_table "matrix_columns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", default: "", null: false
    t.integer "position", default: 0, null: false
    t.bigint "project_matrix_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_matrix_id", "position"], name: "index_matrix_columns_on_project_matrix_id_and_position", unique: true
    t.index ["project_matrix_id"], name: "index_matrix_columns_on_project_matrix_id"
  end

  create_table "matrix_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", default: "", null: false
    t.integer "position", default: 0, null: false
    t.bigint "project_matrix_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_matrix_id", "position"], name: "index_matrix_rows_on_project_matrix_id_and_position", unique: true
    t.index ["project_matrix_id"], name: "index_matrix_rows_on_project_matrix_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.bigint "organization_id"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["recipient_id", "read"], name: "index_notifications_on_recipient_id_and_read"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "okr_cycle_id", null: false
    t.bigint "owner_id"
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.bigint "project_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["okr_cycle_id"], name: "index_objectives_on_okr_cycle_id"
    t.index ["owner_id"], name: "index_objectives_on_owner_id"
    t.index ["project_id"], name: "index_objectives_on_project_id"
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

  create_table "project_matrices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", default: "", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_project_matrices_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_project_matrices_on_project_id"
  end

  create_table "project_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_project_members_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.boolean "approval_all_team", default: false
    t.string "approval_roles", default: [], array: true
    t.boolean "archived", default: false
    t.bigint "assignee_id"
    t.decimal "budget_actual", precision: 15, scale: 2, default: "0.0"
    t.decimal "budget_estimated", precision: 15, scale: 2, default: "0.0"
    t.string "category"
    t.string "color", default: "#6366f1"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "icon", default: "folder"
    t.bigint "manager_id"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.integer "priority", default: 0
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.decimal "project_investment_estimated", precision: 15, scale: 2, default: "0.0"
    t.decimal "proposal_investment_estimated", precision: 15, scale: 2, default: "0.0"
    t.decimal "return_actual", precision: 15, scale: 2, default: "0.0"
    t.decimal "return_estimated", precision: 15, scale: 2, default: "0.0"
    t.bigint "sponsor_id"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["approval_roles"], name: "index_projects_on_approval_roles", using: :gin
    t.index ["assignee_id"], name: "index_projects_on_assignee_id"
    t.index ["manager_id"], name: "index_projects_on_manager_id"
    t.index ["organization_id"], name: "index_projects_on_organization_id"
    t.index ["sponsor_id"], name: "index_projects_on_sponsor_id"
  end

  create_table "risks", force: :cascade do |t|
    t.text "contingency_plan"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "impact", default: 1, null: false
    t.text "mitigation_plan"
    t.string "name", null: false
    t.bigint "owner_id"
    t.integer "probability", default: 1, null: false
    t.bigint "project_id", null: false
    t.string "status", default: "identified", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_risks_on_owner_id"
    t.index ["project_id", "status"], name: "index_risks_on_project_id_and_status"
    t.index ["project_id"], name: "index_risks_on_project_id"
    t.index ["status"], name: "index_risks_on_status"
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

  create_table "tags", force: :cascade do |t|
    t.string "color", default: "#6366f1"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_tags_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_tags_on_organization_id"
  end

  create_table "task_dependencies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dependency_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["dependency_id"], name: "index_task_dependencies_on_dependency_id"
    t.index ["task_id", "dependency_id"], name: "index_task_dependencies_on_task_id_and_dependency_id", unique: true
    t.index ["task_id"], name: "index_task_dependencies_on_task_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.decimal "estimated_hours", precision: 12, scale: 2, default: "0.0"
    t.integer "position", default: 0
    t.integer "priority", default: 0
    t.decimal "progress", precision: 5, scale: 2, default: "0.0"
    t.bigint "project_id", null: false
    t.date "recurrence_end_date"
    t.string "recurrence_rule"
    t.bigint "recurring_parent_id"
    t.string "status", default: "backlog"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["recurring_parent_id"], name: "index_tasks_on_recurring_parent_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration"
    t.datetime "ended_at"
    t.datetime "started_at", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ended_at"], name: "index_time_entries_on_ended_at"
    t.index ["task_id", "user_id"], name: "index_time_entries_on_task_id_and_user_id"
    t.index ["task_id"], name: "index_time_entries_on_task_id"
    t.index ["user_id", "started_at"], name: "index_time_entries_on_user_id_and_started_at"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "locale", default: "en"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "theme", default: "system"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.text "response"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "webhook_id", null: false
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "events", default: "--- []\n", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.string "secret"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["organization_id"], name: "index_webhooks_on_organization_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "organizations"
  add_foreign_key "activity_logs", "projects"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "checklist_items", "tasks"
  add_foreign_key "comments", "tasks"
  add_foreign_key "comments", "users"
  add_foreign_key "custom_field_values", "custom_fields"
  add_foreign_key "custom_fields", "organizations"
  add_foreign_key "dashboard_widgets", "users"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users"
  add_foreign_key "kanban_columns", "projects"
  add_foreign_key "key_results", "objectives"
  add_foreign_key "kpis", "organizations"
  add_foreign_key "kpis", "projects"
  add_foreign_key "kpis", "users", column: "owner_id"
  add_foreign_key "matrix_cells", "matrix_columns"
  add_foreign_key "matrix_cells", "matrix_rows"
  add_foreign_key "matrix_columns", "project_matrices"
  add_foreign_key "matrix_rows", "project_matrices"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "objectives", "okr_cycles"
  add_foreign_key "objectives", "projects"
  add_foreign_key "objectives", "users", column: "owner_id"
  add_foreign_key "okr_cycles", "organizations"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "project_matrices", "projects"
  add_foreign_key "project_members", "projects"
  add_foreign_key "project_members", "users"
  add_foreign_key "projects", "organizations"
  add_foreign_key "projects", "users", column: "assignee_id"
  add_foreign_key "projects", "users", column: "manager_id"
  add_foreign_key "projects", "users", column: "sponsor_id"
  add_foreign_key "risks", "projects"
  add_foreign_key "risks", "users", column: "owner_id"
  add_foreign_key "strategic_canvases", "projects"
  add_foreign_key "tags", "organizations"
  add_foreign_key "task_dependencies", "tasks"
  add_foreign_key "task_dependencies", "tasks", column: "dependency_id"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "tasks", column: "recurring_parent_id"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "time_entries", "tasks"
  add_foreign_key "time_entries", "users"
  add_foreign_key "webhook_deliveries", "webhooks"
  add_foreign_key "webhooks", "organizations"
end
