module Sharting
  module ElasticShart
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def elastic_shart_reindex(options = {})
        reindex(import: false)
        elastic_shart_import unless options[:import] == false
      end

      def elastic_shart_import
        Sharting.each do
          searchkick_import(searchkick_index)
        end
      end

      def elastic_shart_search(term = nil, options = {})
        query = ElasticShart::Query.new(self, term, options)
        if options[:execute] == false
          query
        else
          query.execute
        end
      end
    end

    class Query < Searchkick::Query
      # def initialize(klass, term, options = {})
      #   options[:fields] = Array(options[:fields]) << :current_shard
      #   super
      # end

      def execute
        searchkick_results = super
        Results.new(searchkick_results.klass, searchkick_results.response, searchkick_results.options)
      end

      def params
        super.tap do |base|
          base[:body][:fields] << :current_shard unless base[:body][:fields].include?(:current_shard)
        end
      end
    end

    class Results < Searchkick::Results
      def results
        @results ||= begin
          if options[:load]
            # results can have different types
            results = Hash.new{|hash, key| hash[key] = []}

            hits.group_by{|hit, i| [hit["_type"], hit["fields"]["current_shard"].first] }.each do |(type, shard), grouped_hits|
              Sharting.using(shard.to_sym) do
                records = type.camelize.constantize
                if options[:includes]
                  records = records.includes(options[:includes])
                end
                results[type].concat(
                    if records.respond_to?(:primary_key)
                      records.where(records.primary_key => grouped_hits.map{|hit| hit["_id"] }).to_a
                    else
                      records.queryable.for_ids(grouped_hits.map{|hit| hit["_id"] }).to_a
                    end)
              end
            end

            # sort
            hits.map do |hit|
              results[hit["_type"]].find{|r| r.id.to_s == hit["_id"].to_s }
            end.compact
          else
            super
          end
        end
      end
    end
  end
end