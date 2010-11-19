class AddLatLonDegDec < ActiveRecord::Migration
  def self.up
    add_column :igcpoints, :dlat, :float
    add_column :igcpoints, :dlon, :float
  end

  def self.down
    remove_column :igcpoints, :dlat
    remove_column :igcpoints, :dlon
  end
end
