module Sharting
  module Identification
    def self.included(base)
      base.primary_key = :id
      base.send(:before_create, :assign_id)
    end

    def assign_id
      self.id ||= Sharting.generate_uid
    end
  end
end