class Vehicle < ActiveRecord::Base
  include Sharting::Identification

  belongs_to :user
  has_many :prices
  has_many :options

  def name
    "#{year} #{make} #{model} #{trim}"
  end

  def serializable_hash(*)
    super.merge(
      options: options.map(&:serializable_hash),
      prices: prices.map(&:serializable_hash)
    )
  end
end
