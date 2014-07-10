module HateBase
  class Base
    class Error < StandardError; end
    class RecordNotFound < Error; end

    class_attribute :connection
    class_attribute :table
    class_attribute :columns

    self.columns = {}

    def self.establish_connection(options)
      raise 'Not configured' unless options
      self.connection = Stargate::Client.new(options[:url])
    end

    def self.column(name, options = {})
      self.columns = superclass.columns.dup if self.columns.equal?(superclass.columns)
      self.columns[name.to_sym] = options.dup
      attr_accessor name
    end

    def self.key_column
      (key_column, _) = columns.find{|_, options| options[:key]}
      raise 'No key defined' unless key_column
      key_column
    end

    def self.create(attributes)
      new(attributes).tap(&:save)
    end

    def self.create!(attributes)
      new(attributes).tap(&:save!)
    end

    def self.find(key)
      row = connection.show_row(table.to_s, key)
      return nill unless row
      new(parse_row(row), persisted: true)
    rescue Stargate::RowNotFoundError
      nil
    end

    def self.find!(key)
      find(key).tap{|record| raise RecordNotFound unless record}
    end

    def initialize(attributes, options = {})
      attributes.each{|k, v| send("#{k}=", v)}
      @persisted = options[:persisted]
    end

    def key_column
      self.class.key_column
    end

    def key
      key_column && send(key_column)
    end

    def save(options = {})
      key = options[:key] || self.key
      data = serializable_data
      connection.create_row(table.to_s, key.to_s, Time.now.to_i, data)
      @persisted = true
    rescue
      false
    end

    def save!
      raise 'Save failed' unless save
    end

    def destroy(options = {})
      key = options[:key] || self.key
      connection.delete_row(table.to_s, key.to_s)
      @persisted = false
      @destroyed = true
    end

    def persisted?
      @persisted
    end

    def destroyed?
      @destroyed
    end

    def attributes
      columns.keys.each_with_object({}) do |key, attributes|
        attributes[key] = send(key)
      end
    end

    def serializable_hash
      columns.each_with_object({}) do |(name, options), hash|
        hash["#{options[:family]}:#{name}"] = send(name) unless options[:key]
      end
    end

    def serializable_data
      columns.each_with_object([]) do |(name, options), data|
        data << {name: "#{options[:family]}:#{name}", value: send(name)} unless options[:key]
      end
    end

    private

    def self.parse_row(row)
      attributes = {key_column => deserialize_value(key_column, row.name)}
      columns.each_with_object(attributes) do |(name, options), attrs|
        next if name == key_column
        row_column_name = "#{options[:family]}:#{name}"
        row_column = row.columns.find{|rc| rc.name == row_column_name }
        attrs[name] = deserialize_value(name, row_column.value) if row_column
      end
    end

    def self.deserialize_value(column_name, value)
      case columns[column_name][:type]
        when :integer then value.to_i
        when :float then value.to_f
        else value
      end
    end
  end
end