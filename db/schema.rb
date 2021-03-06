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

ActiveRecord::Schema.define(version: 20170811232514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "games", force: :cascade do |t|
    t.integer "team_id"
    t.string "channel_identifier"
    t.string "player1_identifier"
    t.string "player2_identifier"
    t.string "challenger_identifier"
    t.boolean "complete", default: false
    t.string "winner_identifier"
    t.integer "moves_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_identifier"], name: "index_games_on_channel_identifier"
    t.index ["team_id", "channel_identifier", "complete"], name: "index_team_channel_complete_on_game"
    t.index ["team_id", "channel_identifier"], name: "index_games_on_team_id_and_channel_identifier"
    t.index ["team_id"], name: "index_games_on_team_id"
    t.index ["winner_identifier"], name: "index_games_on_winner_identifier"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "row"
    t.integer "column"
    t.boolean "player1_move", default: false
    t.boolean "player2_move", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
  end

  create_table "teams", force: :cascade do |t|
    t.text "name"
    t.string "slack_identifier"
    t.text "slack_url"
    t.text "email_domain"
    t.text "slack_access_token"
    t.text "slack_icon_url"
    t.string "slack_authorized_user_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slack_identifier"], name: "index_teams_on_slack_identifier"
  end

end
