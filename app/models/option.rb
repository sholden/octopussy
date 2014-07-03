class Option < ActiveRecord::Base
  include Sharting::Identification

  belongs_to :vehicle
end
