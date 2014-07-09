class UserMigrator
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def migrate!(shard_name)
    with_transactions(shard_name) do
      move(user, shard_name) do
        user.vehicles.preload(:prices, :options).each do |vehicle|
          move(vehicle, shard_name) do
            vehicle.prices.each{|p| move(p, shard_name) }
            vehicle.options.each{|o| move(o, shard_name) }
          end
        end
      end.tap(&:touch)
    end
  end

  def move(record, shard_name)
    copy = record.dup
    copy.id = record.id
    copy.current_shard = shard_name
    Sharting.using(shard_name) { copy.save! }
    yield if block_given?
    Sharting.using(record.current_shard) { record.destroy }
    raise 'Migration failed' unless copy.persisted? && copy.current_shard == shard_name
    copy
  end

  def with_transactions(shard_name)
    Sharting.using(user.current_shard) do
      User.transaction do
        Sharting.using(shard_name) do
          User.transaction do
            yield
          end
        end
      end
    end
  end
end