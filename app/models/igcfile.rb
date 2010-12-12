class Igcfile < ActiveRecord::Base
  has_many :igcpoint, :dependent => :destroy
  has_many :windpoint, :dependent => :destroy
end
