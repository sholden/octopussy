class Vehicle < ActiveRecord::Base
  include Sharting::Identification

  belongs_to :user
end
