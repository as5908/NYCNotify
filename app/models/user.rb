class User < ActiveRecord::Base
  has_many :authorizations, :dependent => :destroy
  validates :name, :presence => true
  
end
