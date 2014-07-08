require 'csv'
require 'sharting'

class DataLoader
  attr_reader :data_path, :logger

  def initialize(data_path, logger = Logger.new(STDOUT))
    @data_path = data_path.to_s
    @logger = logger
  end

  def load!
    bool_converter = ->(f) { f =~ /\A(true|false)\Z/ ? f == 'true' : f}

    buyer_headers = [:id, :name, :email]
    buyers_by_id = CSV.open(data_path + '/buyer.csv', headers: buyer_headers, converters: [:all, bool_converter]).index_by{|r| r[:id]}

    vehicle_headers = [:id, :user_id, :year, :make, :model, :trim, :interior_color, :exterior_color, :sticker_price]
    vehicles_by_buyer = CSV.open(data_path + '/vehicle.csv', headers: vehicle_headers, converters: [:all, bool_converter]).group_by{|r| r[:user_id]}

    price_headers = [:vehicle_id, :price]
    prices_by_vehicle = CSV.open(data_path + '/price.csv', headers: price_headers, converters: [:all, bool_converter]).group_by{|r| r[:vehicle_id]}

    option_headers = [:vehicle_id, :description, :opt_code, :is_quick_package, :is_option_package, :is_dio_option, :msrp, :invoice, :opt_kind]
    options_by_vehicle = CSV.open(data_path + '/option.csv', headers: option_headers, converters: [:integer, bool_converter]).group_by{|r| r[:vehicle_id]}

    buyers_by_id.each do |buyer_id, buyer_attributes|
      buyer_attributes = buyer_attributes.to_hash
      Sharting.using_key(buyer_attributes[:email]) do
        user = User.create!(buyer_attributes.except(:id).merge({:password => 'password'}))

        Array(vehicles_by_buyer[buyer_id]).each do |vehicle_attributes|
          vehicle_attributes = vehicle_attributes.to_hash
          vehicle_id = vehicle_attributes.delete(:id)
          vehicle = user.vehicles.create!(vehicle_attributes.except(:user_id))

          Array(prices_by_vehicle[vehicle_id]).each do |price_attributes|
            price_attributes = price_attributes.to_hash.except(:vehicle_id)
            vehicle.prices.create!(price_attributes)
          end

          Array(options_by_vehicle[vehicle_id]).each do |option_attributes|
            option_attributes = option_attributes.to_hash.except(:vehicle_id)
            vehicle.options.create!(option_attributes)
          end
        end

        user.save!
      end
    end
  end
end
