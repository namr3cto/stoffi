class RenameDatesInEvents < ActiveRecord::Migration
  def change
	rename_column :events, :from, :start
	rename_column :events, :until, :stop
  end
end
