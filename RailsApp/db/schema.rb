# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180314130704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "datasources", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "caption"
    t.string   "image_location"
    t.integer  "total_records"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "pii_datasource_id"
    t.string   "access_level"
    t.string   "version"
    t.index ["pii_datasource_id"], :name => "fk__datasources_pii_datasource_id"
    t.foreign_key ["pii_datasource_id"], "datasources", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_datasources_pii_datasource_id"
  end

  create_table "field_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fields", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "concrete_fields", force: true do |t|
    t.integer  "field_category_id"
    t.integer  "datasource_id"
    t.integer  "field_id"
    t.string   "name"
    t.string   "caption"
    t.string   "db_data_type"
    t.string   "ui_data_type"
    t.string   "printf_format"
    t.string   "pg_format"
    t.string   "source_fields",                                   array: true
    t.integer  "position"
    t.integer  "default_output_layout"
    t.integer  "min",                   limit: 8
    t.integer  "max",                   limit: 8
    t.integer  "distinct_count"
    t.boolean  "favorite"
    t.boolean  "record_key"
    t.json     "conflict_values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "numeric_sort"
    t.boolean  "tracked"
    t.boolean  "select_enabled",                  default: false
    t.boolean  "breakdown_enabled",               default: false
    t.boolean  "dedupe_enabled",                  default: false
    t.boolean  "output_enabled",                  default: false
    t.boolean  "sort_enabled",                    default: false
    t.index ["datasource_id"], :name => "index_concrete_fields_on_datasource_id"
    t.index ["field_category_id"], :name => "index_concrete_fields_on_field_category_id"
    t.index ["field_id"], :name => "index_concrete_fields_on_field_id"
    t.foreign_key ["datasource_id"], "datasources", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_concrete_fields_datasource_id"
    t.foreign_key ["field_category_id"], "field_categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_concrete_fields_field_category_id"
    t.foreign_key ["field_id"], "fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_concrete_fields_field_id"
  end

  create_table "companies", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "activation_token"
    t.string   "status"
    t.boolean  "sysadmin"
    t.integer  "company_id"
    t.boolean  "admin"
    t.integer  "created_by"
    t.datetime "activation_expire_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "userid"
    t.string   "auth_code"
    t.string   "auth_token"
    t.index ["company_id"], :name => "fk__users_company_id"
    t.index ["created_by"], :name => "fk__users_created_by"
    t.index ["remember_token"], :name => "index_users_on_remember_token"
    t.foreign_key ["company_id"], "companies", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_company_id"
    t.foreign_key ["created_by"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_created_by"
  end

  create_table "counts", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "datasource_id"
    t.integer  "parent_id"
    t.integer  "result"
    t.boolean  "locked"
    t.boolean  "dirty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["datasource_id"], :name => "fk__counts_datasource_id"
    t.index ["parent_id"], :name => "fk__counts_parent_id"
    t.index ["user_id"], :name => "fk__counts_user_id"
    t.foreign_key ["datasource_id"], "datasources", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_datasource_id"
    t.foreign_key ["parent_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_parent_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_user_id"
  end

  create_table "breakdowns", force: true do |t|
    t.integer  "count_id"
    t.integer  "concrete_field_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concrete_field_id"], :name => "index_breakdowns_on_concrete_field_id"
    t.index ["count_id"], :name => "index_breakdowns_on_count_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_breakdowns_concrete_field_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_breakdowns_count_id"
  end

  create_table "concrete_field_input_methods", force: true do |t|
    t.integer  "concrete_field_id"
    t.integer  "position"
    t.string   "input_method_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",           default: true
    t.index ["concrete_field_id"], :name => "index_concrete_field_input_methods_on_concrete_field_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_concrete_field_input_methods_concrete_field_id"
  end

  create_table "orders", force: true do |t|
    t.integer  "count_id"
    t.integer  "user_id"
    t.integer  "total_cap"
    t.string   "ftp_url"
    t.string   "s3_url"
    t.string   "cap_type"
    t.string   "po_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["count_id"], :name => "fk__orders_count_id"
    t.index ["user_id"], :name => "fk__orders_user_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_orders_count_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_orders_user_id"
  end

  create_table "jobs", force: true do |t|
    t.integer  "count_id"
    t.integer  "order_id"
    t.integer  "user_id"
    t.integer  "total_count"
    t.string   "type"
    t.string   "status"
    t.datetime "queued_at"
    t.datetime "working_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.datetime "killed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["count_id"], :name => "index_jobs_on_count_id"
    t.index ["order_id"], :name => "index_jobs_on_order_id"
    t.index ["user_id"], :name => "fk__jobs_user_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_count_id"
    t.foreign_key ["order_id"], "orders", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_order_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_jobs_user_id"
  end

  create_view "count_summaries", " SELECT tmp.id,\n    tmp.count_id,\n    tmp.user_name,\n    tmp.datasource_name,\n    tmp.most_recent_job_id,\n    tmp.most_recent_job_status,\n    tmp.most_recent_job_updated_at\n   FROM ( SELECT counts.id,\n            counts.id AS count_id,\n            (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS user_name,\n            datasources.name AS datasource_name,\n            jobs.id AS most_recent_job_id,\n            jobs.status AS most_recent_job_status,\n            jobs.updated_at AS most_recent_job_updated_at,\n            rank() OVER (PARTITION BY jobs.count_id ORDER BY jobs.updated_at DESC) AS rank\n           FROM (((counts\n             JOIN users ON ((counts.user_id = users.id)))\n             JOIN datasources ON ((counts.datasource_id = datasources.id)))\n             LEFT JOIN jobs ON ((counts.id = jobs.count_id)))) tmp\n  WHERE (tmp.rank = 1)", :force => true
  create_table "counts_orders", id: false, force: true do |t|
    t.integer "count_id"
    t.integer "order_id"
    t.index ["count_id"], :name => "fk__counts_orders_count_id"
    t.index ["order_id"], :name => "fk__counts_orders_order_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_orders_count_id"
    t.foreign_key ["order_id"], "orders", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_orders_order_id"
  end

  create_table "user_files", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "uploaded_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], :name => "index_user_files_on_deleted_at"
    t.index ["user_id"], :name => "index_user_files_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_files_user_id"
  end

  create_table "counts_user_files", force: true do |t|
    t.integer "count_id"
    t.integer "user_file_id"
    t.integer "concrete_field_id"
    t.index ["concrete_field_id"], :name => "index_counts_user_files_on_concrete_field_id"
    t.index ["count_id"], :name => "fk__counts_user_files_count_id"
    t.index ["user_file_id"], :name => "fk__counts_user_files_user_file_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_user_files_concrete_field_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_user_files_count_id"
    t.foreign_key ["user_file_id"], "user_files", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_counts_user_files_user_file_id"
  end

  create_table "custom_configurations", force: true do |t|
    t.string   "parameter"
    t.json     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datasource_restricted_companies", force: true do |t|
    t.integer "datasource_id"
    t.integer "company_id"
    t.index ["company_id"], :name => "index_datasource_restricted_companies_on_company_id"
    t.index ["datasource_id"], :name => "index_datasource_restricted_companies_on_datasource_id"
    t.foreign_key ["company_id"], "companies", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_datasource_restricted_companies_company_id"
    t.foreign_key ["datasource_id"], "datasources", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_datasource_restricted_companies_datasource_id"
  end

  create_view "datasource_restricted_users", " SELECT datasources.id AS datasource_id,\n    users.id AS user_id\n   FROM ((datasource_restricted_companies\n     JOIN datasources ON ((datasources.id = datasource_restricted_companies.datasource_id)))\n     JOIN users ON ((users.company_id = datasource_restricted_companies.company_id)))\n  WHERE ((datasources.access_level)::text = 'restricted'::text)\nUNION\n SELECT datasources.id AS datasource_id,\n    users.id AS user_id\n   FROM (datasources\n     CROSS JOIN users)\n  WHERE ((datasources.access_level)::text = 'open'::text)", :force => true
  create_table "dedupes", force: true do |t|
    t.integer "count_id"
    t.integer "concrete_field_id"
    t.integer "position"
    t.string  "tiebreak"
    t.index ["concrete_field_id"], :name => "index_dedupes_on_concrete_field_id"
    t.index ["count_id"], :name => "index_dedupes_on_count_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_dedupes_concrete_field_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_dedupes_count_id"
  end

  create_view "ftp_users", " SELECT users.email,\n    '94238c31430b34a2ac79f039b70794015ec9ed8763144f4a76cb0ddca2b324717ea2acc464c865bd70122dea228c3654b3c7ca98d67f29fea67129bc59e67a10'::character varying AS ftp_hash,\n    '41037db285d5b18fa965feee912628c8'::character varying AS ftp_salt,\n    (('/var/ftp/'::character(10))::text || (users.email)::text) AS homedir,\n    '/usr/sbin/nologin'::character(17) AS shell\n   FROM users", :force => true
  create_table "order_statistics", force: true do |t|
    t.integer  "job_id"
    t.integer  "concrete_field_id"
    t.integer  "populated_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concrete_field_id"], :name => "index_order_statistics_on_concrete_field_id"
    t.index ["job_id"], :name => "index_order_statistics_on_job_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_order_statistics_concrete_field_id"
    t.foreign_key ["job_id"], "jobs", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_order_statistics_job_id"
  end

  create_table "outputs", force: true do |t|
    t.integer  "order_id"
    t.integer  "concrete_field_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concrete_field_id"], :name => "index_outputs_on_concrete_field_id"
    t.index ["order_id"], :name => "index_outputs_on_order_id"
    t.foreign_key ["order_id"], "orders", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_outputs_order_id"
  end

  create_table "selects", force: true do |t|
    t.integer  "count_id"
    t.integer  "concrete_field_id"
    t.integer  "position"
    t.integer  "from"
    t.integer  "to"
    t.string   "blanks"
    t.boolean  "has_values"
    t.boolean  "has_ranges"
    t.boolean  "has_blanks_criterion"
    t.boolean  "has_files",            default: false
    t.boolean  "exclude",              default: false
    t.boolean  "linked_to_next"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concrete_field_id"], :name => "index_selects_on_concrete_field_id"
    t.index ["count_id"], :name => "index_selects_on_count_id"
    t.foreign_key ["concrete_field_id"], "concrete_fields", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_selects_concrete_field_id"
    t.foreign_key ["count_id"], "counts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_selects_count_id"
  end

  create_table "selects_user_files", id: false, force: true do |t|
    t.integer "user_file_id"
    t.integer "select_id"
    t.index ["select_id"], :name => "fk__selects_user_files_select_id"
    t.index ["user_file_id"], :name => "fk__selects_user_files_user_file_id"
    t.foreign_key ["select_id"], "selects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_selects_user_files_select_id"
    t.foreign_key ["user_file_id"], "user_files", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_selects_user_files_user_file_id"
  end

  create_table "sorts", force: true do |t|
    t.integer  "order_id"
    t.integer  "concrete_field_id"
    t.integer  "position"
    t.boolean  "descending",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["concrete_field_id"], :name => "index_sorts_on_concrete_field_id"
    t.index ["order_id"], :name => "index_sorts_on_order_id"
    t.foreign_key ["order_id"], "orders", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_sorts_order_id"
  end

end
