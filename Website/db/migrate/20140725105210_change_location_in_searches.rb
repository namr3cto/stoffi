class ChangeLocationInSearches < ActiveRecord::Migration
  def change
	change_column :searches, :longitude, :decimal, precision: 8, scale: 5
	change_column :searches, :latitude, :decimal, precision: 8, scale: 5 
  end
end
