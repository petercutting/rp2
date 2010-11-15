class AddIgcpointsIndex < ActiveRecord::Migration
  def self.up
        add_index :igcpoints, [:igcfile_id, :seq_secs]
  end

  def self.down
        remove_index :igcpoints, [:igcfile_id, :seq_secs]
  end
end
