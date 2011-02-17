class ChangeToWindSpeed < ActiveRecord::Migration
  def self.up
    add_column :igcfiles, :wind_speed, :int
    remove_column :igcfiles, :wind_strength
  end

  def self.down
    add_column :igcfiles, :wind_strength, :int
    remove_column :igcfiles, :wind_speed
  end
end
