class SpeedToFloat < ActiveRecord::Migration
  def self.up
     change_column :igcfiles, :wind_speed, :float
     change_column :windpoints, :speed, :float
  end

  def self.down
     change_column :igcfiles, :wind_speed, :int
     change_column :windpoints, :speed, :int
  end
end
