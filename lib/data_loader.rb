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
    buyers_by_id = CSV.open(data_path + '/buyer.csv', headers: buyer_headers, converters: [:all, bool_converter]).index_by(&:first)

    vehicle_headers = [:id, :user_id, :year, :make, :model, :trim, :interior_color, :exterior_color, :sticker_price]
    vehicles_by_buyer = CSV.open(data_path + '/vehicle.csv', headers: vehicle_headers, converters: [:all, bool_converter]).group_by{|r| r[1]}

    price_headers = [:vehicle_id, :price]
    prices_by_vehicle = CSV.open(data_path + '/price.csv', headers: price_headers, converters: [:all, bool_converter]).group_by(&:first)

    option_headers = [:vehicle_id, :description, :opt_code, :is_quick_package, :is_option_package, :is_dio_option, :msrp, :invoice, :opt_kind]
    options_by_vehicle = CSV.open(data_path + '/option.csv', headers: option_headers, converters: [:all, bool_converter]).group_by(&:first)

    buyers_by_id.each do |buyer_id, buyer_attributes|
      Sharting.using_key(buyer_attributes[:email]) do
        user = User.new(buyer_attributes.except(:id))

        Array(vehicles_by_buyer[buyer_id]).each do |vehicle_attributes|
          vehicle_id = vehicle_attributes.delete(:vehicle_id)
          vehicle = user.vehicles.build(vehicle_attributes)

          Array(prices_by_vehicle[vehicle_id]).each do |price_attributes|
            vehicle.prices.build(price_attributes.except(:vehicle_id))
          end

          Array(options_by_vehicle[vehicle_id]).each do |option_attributes|
            vehicle.options.build(option_attributes.except(:vehicle_id))
          end
        end

        user.save!
      end
    end
  end
end
