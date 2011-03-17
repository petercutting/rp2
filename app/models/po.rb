class Po < ActiveRecord::Base

  validates_uniqueness_of :time
end
