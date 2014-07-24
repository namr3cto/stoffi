# -*- encoding : utf-8 -*-
class AddConfigurationToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :configuration_id, :int
  end
end
