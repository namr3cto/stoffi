class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :venue
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :from
      t.datetime :until
      t.text :content
      t.string :image
      t.string :type

      t.timestamps
    end
  end
end
