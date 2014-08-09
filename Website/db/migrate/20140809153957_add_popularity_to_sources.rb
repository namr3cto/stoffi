class AddPopularityToSources < ActiveRecord::Migration
  def change
    add_column :sources, :popularity, :integer, default: 0
  end
end
