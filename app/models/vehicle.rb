class Vehicle < ActiveRecord::Base
  include Sharting::Identification

  belongs_to :user
  has_many :prices
  has_many :options

  def name
    "#{year} #{make} #{model} #{trim}"
  end
end
