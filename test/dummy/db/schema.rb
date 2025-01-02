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

ActiveRecord::Schema[7.1].define(version: 2024_12_29_060822) do
  create_table "qubit_censuses", force: :cascade do |t|
    t.string "name"
    t.integer "owner_id", null: false
    t.string "description"
    t.string "condition"
    t.string "subject_type"
    t.integer "sample_size"
    t.decimal "sample_rate"
    t.string "status"
    t.integer "matched"
    t.integer "surveyed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_qubit_censuses_on_owner_id"
    t.index ["status"], name: "index_qubit_censuses_on_status"
  end

  create_table "qubit_events", force: :cascade do |t|
    t.integer "qubit_variant_id"
    t.string "subject_type"
    t.integer "subject_id"
    t.string "event_type"
    t.json "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_qubit_events_on_event_type"
    t.index ["qubit_variant_id"], name: "index_qubit_events_on_qubit_variant_id"
    t.index ["subject_type", "subject_id"], name: "index_qubit_events_on_subject"
  end

  create_table "qubit_overrides", force: :cascade do |t|
    t.integer "qubit_test_id"
    t.integer "overrider_id", null: false
    t.string "subject_type"
    t.integer "subject_id"
    t.integer "qubit_variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["overrider_id"], name: "index_qubit_overrides_on_overrider_id"
    t.index ["qubit_test_id"], name: "index_qubit_overrides_on_qubit_test_id"
    t.index ["qubit_variant_id"], name: "index_qubit_overrides_on_qubit_variant_id"
    t.index ["subject_type", "subject_id"], name: "index_qubit_overrides_on_subject"
  end

  create_table "qubit_test_changes", force: :cascade do |t|
    t.integer "qubit_test_id"
    t.integer "user_id"
    t.string "change_type"
    t.json "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qubit_test_id"], name: "index_qubit_test_changes_on_qubit_test_id"
    t.index ["user_id"], name: "index_qubit_test_changes_on_user_id"
  end

  create_table "qubit_tests", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.integer "owner_id", null: false
    t.string "description"
    t.string "condition"
    t.string "subject_type"
    t.integer "control_id"
    t.json "traffic_allocation"
    t.integer "holdout_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["control_id"], name: "index_qubit_tests_on_control_id"
    t.index ["holdout_id"], name: "index_qubit_tests_on_holdout_id"
    t.index ["owner_id"], name: "index_qubit_tests_on_owner_id"
    t.index ["status"], name: "index_qubit_tests_on_status"
  end

  create_table "qubit_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "qubit_variants", force: :cascade do |t|
    t.integer "qubit_test_id"
    t.string "name"
    t.string "description"
    t.json "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qubit_test_id"], name: "index_qubit_variants_on_qubit_test_id"
  end

  add_foreign_key "qubit_overrides", "qubit_users", column: "overrider_id"
end
