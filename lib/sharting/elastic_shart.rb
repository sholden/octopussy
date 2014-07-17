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
      def initialize(klass, term, options = {})
        options[:select] = Array(options[:select]) << :current_shard
        super
      end

      private

      def build_results(response, opts)
        ElasticShart::Results.new(searchkick_klass, response, opts)
      end
    end

    class Results < Searchkick::Results
      def results
        @results ||= begin
          if options[:load]
            # results can have different types
            results = Hash.new{|hash, key| hash[key] = []}

            hits.group_by{|hit, i| [hit["_type"], hit["current_shard"]] }.each do |(type, shard), grouped_hits|
              #TODO: Need to pull current shard from hits, but not returning yet.
              Sharting.each do
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