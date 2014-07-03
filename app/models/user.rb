class User < ActiveRecord::Base
  include Sharting::Identification

  has_many :vehicles
end
