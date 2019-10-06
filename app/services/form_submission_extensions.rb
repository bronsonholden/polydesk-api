class FormSubmissionExtensions
  def initialize(payload)
    @payload = payload.deep_dup
    @meta_aggregates = @payload.fetch('meta-aggregate', '').split(',')

    # If any aggregates are being sorted, include them
    @agg_sorting = @payload.fetch('sort', '').split(',').select { |col|
      col.match(/^-?(refcount|refsum)\(([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)
    }
    @agg_sorting.each { |sort|
      s = sort
      if s.starts_with?('-')
        s = s[1..-1]
      end
      if !@meta_aggregates.include?(s)
        @meta_aggregates.push(s)
      end
    }

    # Modify payload to include any aggregates pulled form sort query param
    @payload['meta-aggregate'] = @meta_aggregates.join(',')

    @aggregate_ops = @meta_aggregates.map { |col|
      m = col.match(/^(refcount|refsum)\((\d+):([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)

      if !m.nil?
        rel_form_id = m[2]
        local_alias = m[3].split('.').join('__')
        external_alias = m[4].split('.').join('__')

        local = m[3].split('.').reduce('data') { |sql, part|
          "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
        }
        external = m[4].split('.').reduce('data') { |sql, part|
          "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
        }

        res = {
          op: m[1],
          rel_form_id: rel_form_id,
          local: local,
          local_alias: local_alias,
          external: external,
          external_alias: external_alias
        }

        if !m[5].nil?
          dimension = m[5].split('.').reduce('data') { |sql, part|
            "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
          }
          dimension_alias = m[5].split('.').join('__')
          res[:dimension] = dimension
          res[:dimension_alias] = dimension_alias
        end

        res
      else
        nil
      end
    }.reject(&:nil?)
  end

  def apply(scope)
    @aggregate_ops.each_with_index { |agg, i|
      if agg[:op] == 'refcount'
        col_name = "count_#{agg[:local_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0) AS #{col_name}").joins("left join (select count(id) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
      if agg[:op] == 'refsum'
        col_name = "sum_#{agg[:local_alias]}_#{agg[:dimension_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0.0) as #{col_name}").joins("left join (select sum((#{Arel.sql(agg[:dimension])})::numeric) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
    }
    return scope
  end

  def payload
    @payload
  end
end
