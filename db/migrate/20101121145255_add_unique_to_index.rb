class AddUniqueToIndex < ActiveRecord::Migration
  def self.up
        remove_index :igcpoints, [:igcfile_id, :seq_secs]
        add_index :igcpoints, [:igcfile_id, :seq_secs], :unique => true
  end

  def self.down
        remove_index :igcpoints, [:igcfile_id, :seq_secs]
        add_index :igcpoints, [:igcfile_id, :seq_secs]
  end
end
