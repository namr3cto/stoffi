class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url
      t.references :resource, polymorphic: true, index: true
      t.integer :width
      t.integer :height

      t.timestamps
    end
    add_index :images, :url, unique: true
  end
end
