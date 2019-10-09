class FormSubmissionExtensions
  def initialize(payload)
    @payload = payload.deep_dup
    @meta_aggregates = @payload.fetch('meta-aggregate', '').split(',')
    @meta_includes = @payload.fetch('meta-include', '').split(',')

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
      m = col.match(/^(refcount|refdistinct|refsum|refavg|refmin|refmax)\((\d+):([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)

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
      if agg[:op] == 'refdistinct'
        col_name = "distinct_#{agg[:local_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0) AS #{col_name}").joins("left join (select count(distinct #{Arel.sql(agg[:dimension])}) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
      if agg[:op] == 'refsum'
        col_name = "sum_#{agg[:local_alias]}_#{agg[:dimension_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0.0) as #{col_name}").joins("left join (select sum((#{Arel.sql(agg[:dimension])})::numeric) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
      if agg[:op] == 'refavg'
        col_name = "avg_#{agg[:local_alias]}_#{agg[:dimension_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0.0) as #{col_name}").joins("left join (select avg((#{Arel.sql(agg[:dimension])})::numeric) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
      if agg[:op] == 'refmin'
        col_name = "min_#{agg[:local_alias]}_#{agg[:dimension_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0.0) as #{col_name}").joins("left join (select min((#{Arel.sql(agg[:dimension])})::numeric) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
      if agg[:op] == 'refmax'
        col_name = "max_#{agg[:local_alias]}_#{agg[:dimension_alias]}"
        scope = scope.select("#{FormSubmission.table_name}.*, coalesce(rel#{i}.#{col_name}, 0.0) as #{col_name}").joins("left join (select max((#{Arel.sql(agg[:dimension])})::numeric) as #{col_name}, #{Arel.sql(agg[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(agg[:rel_form_id])} group by #{Arel.sql(agg[:external])}) as rel#{i} on rel#{i}.rel_dim = id::text")
      end
    }
    @meta_includes.each_with_index { |incl, i|
      m = incl.match(/^select\((\d+):([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+)\)$/)
      form_id = m[1]
      local = m[2].split('.').reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }
      external = m[3].split('.').reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }
      external_alias = m[3].split('.').unshift(m[2]).join('__')
      scope = scope.select_append("incl#{i}.incl_dim as #{external_alias}").joins("left join (select id as incl_id, #{external} as incl_dim from form_submissions where form_id = #{form_id}) as incl#{i} on #{local} = incl_id::text")
    }
    return scope
  end

  def payload
    @payload
  end
end
