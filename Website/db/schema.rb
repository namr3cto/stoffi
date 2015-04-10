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

ActiveRecord::Schema.define(version: 20150410165947) do

  create_table "admin_configs", force: true do |t|
    t.string   "name"
    t.integer  "pending_donations_limit", default: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_translatees", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "size"
  end

  create_table "admin_translatees_admin_translatee_params", id: false, force: true do |t|
    t.integer "admin_translatee_id"
    t.integer "admin_translatee_param_id"
  end

  create_table "admin_translation_parameters", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "example"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums", force: true do |t|
    t.string   "title"
    t.integer  "year"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "archetype_id"
    t.string   "archetype_type"
  end

  add_index "albums", ["archetype_id", "archetype_type"], name: "index_albums_on_archetype_id_and_archetype_type"

  create_table "albums_artists", id: false, force: true do |t|
    t.integer "album_id"
    t.integer "artist_id"
  end

  add_index "albums_artists", ["artist_id", "album_id"], name: "by_album_and_artist", unique: true

  create_table "albums_songs", id: false, force: true do |t|
    t.integer "song_id"
    t.integer "album_id"
  end

  add_index "albums_songs", ["album_id", "song_id"], name: "by_album_and_song", unique: true

  create_table "artists", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.string   "donatable_status", default: "ok"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "googleplus"
    t.string   "myspace"
    t.string   "spotify"
    t.string   "youtube"
    t.string   "soundcloud"
    t.string   "website"
    t.string   "lastfm"
    t.integer  "archetype_id"
    t.string   "archetype_type"
  end

  add_index "artists", ["archetype_id", "archetype_type"], name: "index_artists_on_archetype_id_and_archetype_type"
  add_index "artists", ["name"], name: "by_name", unique: true

  create_table "artists_genres", id: false, force: true do |t|
    t.integer "artist_id", null: false
    t.integer "genre_id",  null: false
  end

  add_index "artists_genres", ["genre_id", "artist_id"], name: "index_artists_genres_on_genre_id_and_artist_id", unique: true

  create_table "artists_songs", id: false, force: true do |t|
    t.integer "artist_id"
    t.integer "song_id"
  end

  add_index "artists_songs", ["artist_id", "song_id"], name: "by_artist_and_song", unique: true

  create_table "client_applications", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          limit: 40
    t.string   "secret",       limit: 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_16"
    t.string   "icon_64"
    t.string   "description"
    t.string   "author"
    t.string   "author_url"
    t.string   "icon_512"
  end

  add_index "client_applications", ["key"], name: "index_client_applications_on_key", unique: true

  create_table "column_sorts", force: true do |t|
    t.integer  "user_id"
    t.integer  "column_id"
    t.string   "field"
    t.boolean  "ascending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "columns", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_config_id"
    t.string   "name"
    t.string   "text"
    t.string   "binding"
    t.string   "sort_field"
    t.boolean  "is_always_visible"
    t.boolean  "is_sortable"
    t.float    "width"
    t.boolean  "is_visible"
    t.string   "alignment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "media_state"
    t.integer  "current_track_id"
    t.string   "currently_selected_navigation"
    t.string   "currently_active_navigation"
    t.string   "shuffle"
    t.string   "repeat"
    t.float    "volume"
    t.float    "seek"
    t.string   "search_policy"
    t.string   "upgrade_policy"
    t.string   "add_policy"
    t.string   "play_policy"
    t.integer  "history_list_config_id"
    t.integer  "queue_list_config_id"
    t.integer  "files_list_config_id"
    t.integer  "youtube_list_config_id"
    t.integer  "sources_list_config_id"
    t.integer  "current_shortcut_profile"
    t.integer  "current_equalizer_profile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "last_ip"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_application_id"
    t.integer  "configuration_id"
    t.string   "status",                default: "offline"
    t.string   "channels",              default: ""
  end

  create_table "donations", force: true do |t|
    t.integer  "artist_id"
    t.decimal  "artist_percentage"
    t.decimal  "stoffi_percentage"
    t.decimal  "charity_percentage"
    t.decimal  "amount"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "return_policy",      default: 0
    t.string   "message"
    t.string   "status",             default: "pending"
  end

  create_table "downloads", force: true do |t|
    t.string   "ip"
    t.string   "channel"
    t.string   "arch"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equalizer_profiles", force: true do |t|
    t.string   "name"
    t.boolean  "is_protected"
    t.string   "levels"
    t.float    "echo_level"
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.string   "venue"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "start"
    t.datetime "stop"
    t.text     "content"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "archetype_id"
    t.string   "archetype_type"
  end

  add_index "events", ["archetype_id", "archetype_type"], name: "index_events_on_archetype_id_and_archetype_type"

  create_table "followings", force: true do |t|
    t.integer "follower_id"
    t.string  "follower_type"
    t.integer "followee_id"
    t.string  "followee_type"
  end

  add_index "followings", ["followee_id", "followee_type"], name: "index_followings_on_followee_id_and_followee_type"
  add_index "followings", ["follower_id", "follower_type"], name: "index_followings_on_follower_id_and_follower_type"

  create_table "genres", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "archetype_id"
    t.string   "archetype_type"
  end

  add_index "genres", ["archetype_id", "archetype_type"], name: "index_genres_on_archetype_id_and_archetype_type"

  create_table "genres_songs", id: false, force: true do |t|
    t.integer "song_id",  null: false
    t.integer "genre_id", null: false
  end

  add_index "genres_songs", ["genre_id", "song_id"], name: "index_genres_songs_on_genre_id_and_song_id", unique: true

  create_table "histories", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories_songs", id: false, force: true do |t|
    t.integer "history_id"
    t.integer "song_id"
  end

  create_table "images", force: true do |t|
    t.string   "url"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["resource_id", "resource_type"], name: "index_images_on_resource_id_and_resource_type"
  add_index "images", ["url"], name: "index_images_on_url", unique: true

  create_table "keyboard_shortcut_profiles", force: true do |t|
    t.string   "name"
    t.boolean  "is_protected"
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keyboard_shortcuts", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "category"
    t.string   "keys"
    t.boolean  "is_global"
    t.integer  "keyboard_shortcut_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.string   "native_name"
    t.string   "english_name"
    t.string   "iso_tag"
    t.string   "ietf_tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link_backlogs", force: true do |t|
    t.integer  "link_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "error"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "do_share",            default: true
    t.boolean  "do_listen",           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "do_donate",           default: true
    t.boolean  "do_create_playlist",  default: true
    t.boolean  "show_button",         default: true
    t.string   "refresh_token"
    t.datetime "token_expires_at"
    t.string   "encrypted_uid"
    t.string   "access_token"
    t.string   "access_token_secret"
  end

  create_table "list_configs", force: true do |t|
    t.integer  "user_id"
    t.string   "selected_indices"
    t.string   "filter"
    t.boolean  "use_icons"
    t.boolean  "accept_file_drops"
    t.boolean  "is_drag_sortable"
    t.boolean  "is_click_sortable"
    t.boolean  "lock_sort_on_number"
    t.integer  "configuration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listens", force: true do |t|
    t.integer  "user_id"
    t.integer  "song_id"
    t.integer  "playlist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_id"
    t.datetime "ended_at"
    t.integer  "album_id"
    t.integer  "album_position"
    t.datetime "started_at"
  end

  create_table "oauth_nonces", force: true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true

  create_table "oauth_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "type",                  limit: 20
    t.integer  "client_application_id"
    t.string   "token",                 limit: 40
    t.string   "secret",                limit: 40
    t.string   "callback_url"
    t.string   "verifier",              limit: 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "valid_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], name: "index_oauth_tokens_on_token", unique: true

  create_table "performances", id: false, force: true do |t|
    t.integer "artist_id", null: false
    t.integer "event_id",  null: false
  end

  add_index "performances", ["artist_id", "event_id"], name: "index_performances_on_artist_id_and_event_id", unique: true
  add_index "performances", ["event_id", "artist_id"], name: "index_performances_on_event_id_and_artist_id", unique: true

  create_table "playlists", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.boolean  "is_public",  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filter"
  end

  add_index "playlists", ["user_id", "name"], name: "by_user_and_name", unique: true

  create_table "playlists_songs", id: false, force: true do |t|
    t.integer "playlist_id"
    t.integer "song_id"
  end

  add_index "playlists_songs", ["playlist_id", "song_id"], name: "by_playlist_and_song", unique: true

  create_table "queues", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queues_songs", id: false, force: true do |t|
    t.integer "queue_id"
    t.integer "song_id"
  end

  create_table "searches", force: true do |t|
    t.string   "query",                              null: false
    t.integer  "user_id"
    t.string   "page",                               null: false
    t.decimal  "latitude",   precision: 8, scale: 5
    t.decimal  "longitude",  precision: 8, scale: 5
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "categories"
    t.string   "sources"
  end

  create_table "shares", force: true do |t|
    t.integer  "user_id"
    t.integer  "playlist_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_id"
    t.integer  "resource_id"
    t.string   "resource_type"
  end

  create_table "song_relations", force: true do |t|
    t.integer "song1_id"
    t.integer "song2_id"
    t.integer "user_id"
    t.integer "weight"
  end

  add_index "song_relations", ["song1_id"], name: "index_song_relations_on_song1_id"
  add_index "song_relations", ["song2_id"], name: "index_song_relations_on_song2_id"
  add_index "song_relations", ["user_id"], name: "index_song_relations_on_user_id"

  create_table "songs", force: true do |t|
    t.string   "title"
    t.string   "genre"
    t.float    "length"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score"
    t.string   "foreign_url"
    t.string   "art_url"
    t.datetime "analyzed_at"
    t.integer  "archetype_id"
    t.string   "archetype_type"
  end

  add_index "songs", ["archetype_id", "archetype_type"], name: "index_songs_on_archetype_id_and_archetype_type"

  create_table "songs_artists", id: false, force: true do |t|
    t.integer "song_id"
    t.integer "artist_id"
  end

  create_table "songs_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "song_id"
  end

  add_index "songs_users", ["user_id", "song_id"], name: "by_song_and_user", unique: true

  create_table "sources", force: true do |t|
    t.string   "name"
    t.string   "foreign_id"
    t.string   "foreign_url"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "length"
    t.integer  "popularity",    default: 0
  end

  add_index "sources", ["resource_id", "resource_type"], name: "index_sources_on_resource_id_and_resource_type"

  create_table "translations", force: true do |t|
    t.integer  "language_id"
    t.integer  "translatee_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "image"
    t.string   "name_source"
    t.boolean  "has_password",           default: true
    t.string   "custom_name"
    t.string   "show_ads",               default: "all"
    t.string   "unique_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "translation_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wikipedia_links", force: true do |t|
    t.integer "resource_id"
    t.string  "resource_type"
    t.string  "locale"
    t.string  "page"
  end

  add_index "wikipedia_links", ["resource_id", "resource_type"], name: "index_wikipedia_links_on_resource_id_and_resource_type"

end
