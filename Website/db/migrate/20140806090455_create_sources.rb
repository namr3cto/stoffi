class CreateSources < ActiveRecord::Migration
  def change
    drop_table :sources if ActiveRecord::Base.connection.table_exists? :sources
    create_table :sources do |t|
      t.string :name
      t.string :foreign_id
      t.string :foreign_url
      t.references :resource, polymorphic: true, index: true

      t.timestamps
    end
    add_index :sources, :foreign_url, unique: true
  end
end
