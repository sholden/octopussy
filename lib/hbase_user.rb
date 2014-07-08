class HbaseUser
  attr_accessor :row, :columns, :attributes

  def initialize(row)
    @row = row
    @columns = row.columns
    @attributes = columns.inject({}) {|ret,val| ret.merge!(val.name.gsub('data:','').to_sym => val.value); ret}
  end
  
  def method_missing(sym,*args,&block)
    if (val = attributes[sym])
      val.inspect.match(/\\x/) ? val.unpack('H*').first.to_i(16) : val
    else
      super sym,args,block
    end
  end

  def self.create(key,data)
    connection.create_row(table,key,Time.now.to_i,data)
  end

  def self.find(uid)
    row = connection.show_row(table,uid)
    new(row)
  end
  
  def self.connection
    Rails.configuration.stargate_connection
  end

  def self.table
    "users"
  end
end
