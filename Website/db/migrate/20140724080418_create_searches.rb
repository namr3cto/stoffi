class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :query, null: false
      t.integer :user_id
      t.string :page, null: false
      t.integer :latitude
      t.integer :longitude
      t.string :locale

      t.timestamps
    end
  end
end
