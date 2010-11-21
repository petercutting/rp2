class UseRadsInstead < ActiveRecord::Migration
  def self.up
    add_column :igcpoints, :rlat, :float
    add_column :igcpoints, :rlon, :float
    remove_column :igcpoints, :dlat
    remove_column :igcpoints, :dlon
    remove_column :igcpoints, :flat
    remove_column :igcpoints, :flon
  end

  def self.down
    remove_column :igcpoints, :rlat
    remove_column :igcpoints, :rlon
    add_column :igcpoints, :dlat, :float
    add_column :igcpoints, :dlon, :float
    add_column :igcpoints, :flat, :float
    add_column :igcpoints, :flon, :float
  end
end
