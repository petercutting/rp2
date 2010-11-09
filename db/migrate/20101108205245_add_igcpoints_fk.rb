class AddIgcpointsFk < ActiveRecord::Migration
  def self.up
    add_column :igcpoints, :igcfile_id, :integer
  end

  def self.down
    remove_column :igcpoints, :igcfile_id
  end
end
