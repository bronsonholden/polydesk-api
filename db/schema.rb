# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_02_051611) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.index ["account_id", "user_id"], name: "index_account_users_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_users_on_account_id"
    t.index ["user_id"], name: "index_account_users_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_accounts_on_discarded_at"
  end

  create_table "blueprints", force: :cascade do |t|
    t.string "name", null: false
    t.string "namespace", null: false
    t.json "schema", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_blueprints_on_name", unique: true
    t.index ["namespace"], name: "index_blueprints_on_namespace", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content"
    t.integer "file_size"
    t.string "content_type"
    t.datetime "discarded_at"
    t.bigint "folder_id", default: 0, null: false
    t.integer "unique_enforcer", limit: 2, default: 0
    t.jsonb "content_data"
    t.index ["discarded_at"], name: "index_documents_on_discarded_at"
    t.index ["folder_id", "name", "unique_enforcer"], name: "index_documents_on_folder_id_and_name_and_unique_enforcer", unique: true
  end

  create_table "folders", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unique_enforcer", limit: 2, default: 0
    t.datetime "discarded_at"
    t.bigint "folder_id"
    t.index ["discarded_at"], name: "index_folders_on_discarded_at"
    t.index ["folder_id", "name", "unique_enforcer"], name: "index_folders_on_folder_id_and_name_and_unique_enforcer", unique: true
    t.index ["folder_id"], name: "index_folders_on_folder_id"
  end

  create_table "form_submission_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.json "metadata", default: {}
    t.integer "sort_key", null: false
    t.integer "form_submission_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", null: false
    t.index ["form_submission_id", "most_recent"], name: "index_form_submission_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["form_submission_id", "sort_key"], name: "index_form_submission_transitions_parent_sort", unique: true
  end

  create_table "form_submissions", force: :cascade do |t|
    t.bigint "submitter_id"
    t.jsonb "data", null: false
    t.jsonb "flat_data", null: false
    t.text "schema_snapshot", default: "{}"
    t.jsonb "layout_snapshot", default: {}
    t.bigint "form_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((flat_data ->> 'value'::text))", name: "index_form_submissions_on_flat_data_value"
    t.index ["form_id"], name: "index_form_submissions_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "schema", default: "{}", null: false
    t.jsonb "layout", default: {}, null: false
    t.datetime "discarded_at"
    t.string "unique_fields", array: true
    t.index ["discarded_at"], name: "index_forms_on_discarded_at"
    t.index ["name"], name: "index_forms_on_name", unique: true
  end

  create_table "options", force: :cascade do |t|
    t.integer "name", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_options_on_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "code", null: false
    t.bigint "account_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "account_user_id"], name: "index_permissions_on_code_and_account_user_id", unique: true
  end

  create_table "prefabs", force: :cascade do |t|
    t.bigint "blueprint_id"
    t.string "namespace", null: false
    t.integer "tag", null: false
    t.json "schema", null: false
    t.json "view", null: false
    t.jsonb "data", null: false
    t.index ["blueprint_id"], name: "index_prefabs_on_blueprint_id"
    t.index ["namespace", "tag"], name: "index_prefabs_on_namespace_and_tag", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "nickname"
    t.string "image"
    t.string "email", null: false
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_account_id"
    t.string "first_name"
    t.string "last_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["default_account_id"], name: "index_users_on_default_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "form_submission_transitions", "form_submissions"
  add_foreign_key "form_submissions", "forms"
  add_foreign_key "prefabs", "blueprints"
  add_foreign_key "users", "accounts", column: "default_account_id"
end
