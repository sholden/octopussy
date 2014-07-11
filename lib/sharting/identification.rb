module Sharting
  module Identification
    def self.included(base)
      base.primary_key = :id
      base.send(:before_create, :assign_id)
    end

    def assign_id
      self.id ||= Sharting.generate_uid(respond_to?(:current_shard) && current_shard || Sharting.current_shard)
    end
  end
end
