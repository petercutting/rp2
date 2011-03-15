class CreateBbs < ActiveRecord::Migration
  def self.up
    create_table :bbs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :bbs
  end
end
