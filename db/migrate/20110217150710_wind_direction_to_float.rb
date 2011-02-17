class WindDirectionToFloat < ActiveRecord::Migration
  def self.up
     change_column :igcfiles, :wind_direction, :float
  end

  def self.down
     change_column :igcfiles, :wind_direction, :int
  end
end
