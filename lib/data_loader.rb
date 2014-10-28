require 'csv'
require 'sharting'

class DataLoader
  attr_reader :data_path, :logger
  BOOL_CONVERTER = ->(f) { f =~ /\A(true|false)\Z/ ? f == 'true' : f}

  def initialize(data_path, logger = Logger.new(STDOUT))
    @data_path = data_path.to_s
    @logger = logger
  end

  def csv_io(file)
    IO.popen("tar -zxOf #{data_path} data/#{file}.csv")
  end

  def load!
    buyer_map = {}

    buyer_csv.each do |buyer_row|
      next unless buyer_row[:email]
      Sharting.using_key(buyer_row[:email]) do
        buyer_attributes = buyer_row.to_hash
        User.create!(buyer_attributes.except(:id).merge({:password => 'password'}))
        buyer_map[buyer_attributes[:id]] = buyer_attributes[:email]
      end
    end

    current_user = nil

    price_groups = each_price_group
    option_groups = each_option_group

    next_price_vehicle_id, next_price_group = price_groups.next
    next_option_vehicle_id, next_option_group = option_groups.next

    vehicle_csv.each do |vehicle_row|
      next unless vehicle_row[:user_id]
      vehicle_attributes = vehicle_row.to_hash

      user_email = buyer_map[vehicle_attributes[:user_id]]
      next unless user_email

      Sharting.using_key(user_email) do
        current_user = User.find_by_email(user_email) if current_user.try(:email) != user_email

        vehicle_id = vehicle_attributes.delete(:id)
        vehicle = current_user.vehicles.create!(vehicle_attributes.except(:user_id))

        while next_price_vehicle_id && next_price_vehicle_id < vehicle_id
          begin
            next_price_vehicle_id, next_price_group = price_groups.next
          rescue StopIteration
            next_price_vehicle_id, next_price_group = nil, nil
          end
        end

        if next_price_vehicle_id == vehicle_id
          next_price_group.each do |price_row|
            price_attributes = price_row.to_hash.except(:vehicle_id)
            vehicle.prices.create!(price_attributes)
          end
        end

        while next_option_vehicle_id && next_option_vehicle_id < vehicle_id
          begin
            next_option_vehicle_id, next_option_group = option_groups.next
          rescue StopIteration
            next_option_vehicle_id, next_option_group = nil, nil
          end
        end

        if next_option_vehicle_id == vehicle_id
          next_option_group.each do |option_row|
            option_attributes = option_row.to_hash.except(:vehicle_id)
            vehicle.options.create!(option_attributes)
          end
        end

        vehicle.save!
      end
    end
  end

  def buyer_csv
    buyer_headers = [:id, :name, :email]
    CSV.new(csv_io('buyer'), headers: buyer_headers, converters: [:all, BOOL_CONVERTER])
  end

  def vehicle_csv
    vehicle_headers = [:id, :user_id, :year, :make, :model, :trim, :interior_color, :exterior_color, :sticker_price]
    CSV.new(csv_io('vehicle'), headers: vehicle_headers, converters: [:all, BOOL_CONVERTER])
  end

  def each_price_group
    if block_given?
      price_headers = [:vehicle_id, :price]
      prices_csv = CSV.new(csv_io('price'), headers: price_headers, converters: [:all, BOOL_CONVERTER])
      each_group_by_key(:vehicle_id, prices_csv) do |vehicle_id, prices|
        yield(vehicle_id, prices)
      end
    else
      to_enum(:each_price_group)
    end
  end

  def each_option_group
    if block_given?
      option_headers = [:vehicle_id, :description, :opt_code, :is_quick_package, :is_option_package,
                        :is_dio_option, :msrp, :invoice, :opt_kind]
      csv = CSV.new(csv_io('option'), headers: option_headers, converters: [:integer, BOOL_CONVERTER])
      each_group_by_key(:vehicle_id, csv) do |vehicle_id, options|
        yield(vehicle_id, options)
      end
    else
      to_enum(:each_option_group)
    end
  end

  def each_group_by_key(key, csv)
    grouping_key_value = nil
    grouped_items = []

    while next_row = csv.shift
      puts next_row.inspect
      grouping_key_value ||= next_row[key]
      if grouping_key_value == next_row[key]
        grouped_items << next_row
      else
        yield(grouping_key_value, grouped_items)
        grouping_key_value = next_row[key]
        grouped_items = [next_row]
      end
    end

    if grouped_items.any?
      yield(grouping_key_value, grouped_items)
    end
  end
end
