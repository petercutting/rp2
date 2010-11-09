class CreateIgcpoints < ActiveRecord::Migration
  def self.up
    create_table :igcpoints do |t|
      t.string :lat
      t.string :lon
      t.integer :enl

      t.timestamps
    end
  end

  def self.down
    drop_table :igcpoints
  end
end
