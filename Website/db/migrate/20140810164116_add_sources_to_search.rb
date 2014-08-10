class AddSourcesToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :sources, :string
  end
end
