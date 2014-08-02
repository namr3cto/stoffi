class CreateWikipediaLinks < ActiveRecord::Migration
  def change
    create_table :wikipedia_links do |t|
      t.references :object, polymorphic: true, index: true
      t.string :locale
      t.string :page
    end
  end
end
