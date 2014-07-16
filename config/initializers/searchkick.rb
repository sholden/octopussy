module Searchkick

  class Results
    def sharded?
      defined?(Sharting)
    end

    def results
      @results ||= begin
        if options[:load]
          # results can have different types
          results = {}
          return_array = []
          hits.group_by{|hit, i| hit["_type"] }.each do |type, grouped_hits|
            records = type.camelize.constantize

            if sharded?
              hits_with_shard_ids = grouped_hits.inject({}) {|ret,val|
                shard_id = Sharting.shard_from_uid(val["_id"].to_i)
                ret[shard_id] ? (ret[shard_id] << val) : (ret[shard_id] = [val])
                ret
              }

              results[type] = []
              hits_with_shard_ids.each {|key,hits|
                sub_results = []
                Sharting.using(Sharting.shard_name(key)) do
                  sub_results << do_queries(hits,records)
                end
                results[type]  << sub_results.flatten
              }
              results[type].flatten!
            else
              results[type] = do_queries(grouped_hits,records)
            end

         # sort
            return_array = hits.map do |hit|
              results[hit["_type"]].find{|r| r.id.to_s == hit["_id"].to_s }
            end.compact
          end
          return_array
        else
          hits.map do |hit|
            result =
                if hit["_source"]
                  hit.except("_source").merge(hit["_source"])
                else
                  hit.except("fields").merge(hit["fields"])
                end
            result["id"] ||= result["_id"] # needed for legacy reasons
            Hashie::Mash.new(result)
          end
        end
      end
    end

    def do_queries(grouped_hits,records)
      if options[:includes]
        records = records.includes(options[:includes])
      end

      if records.respond_to?(:primary_key)
        records.where(records.primary_key => grouped_hits.map{|hit| hit["_id"] }).to_a
      else
        records.queryable.for_ids(grouped_hits.map{|hit| hit["_id"] }).to_a
      end
    end


  end
end
