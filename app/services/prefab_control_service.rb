# Applies data and access controls, removing Prefabs from the given scope
# if A) there are zero "allow" controls the match the Prefab or B) there is at
# least one "deny" control that matches the prefab.
#
# This "scrubbing" process is done with left joins coupled with exclusion of
# rows that have no controls applied (i.e. the "mode" column is null).
class PrefabControlService
  attr_reader :account_user

  def initialize(account_user)
    @account_user = account_user
  end

  # Applies controls by using subqueries that must return a "mode" qualifier
  # of 1 (allow). Prefabs with no controls applied are excluded, as access
  # is granted on a whitelist-basis, with an overriding blacklist.
  def apply(scope)
    inner_sql = scope
      .joins(
        <<-SQL
          left join (
            select
              account_user_groups.account_user_id AS "account_user_id",
              data_controls.namespace AS "namespace",
              data_controls.key AS "key",
              data_controls.value AS "value",
              data_controls.operator AS "operator",
              min(data_controls.mode) AS "mode"
            from
              data_controls
              left join account_user_groups
                on data_controls.group_id = account_user_groups.group_id
            where account_user_groups.account_user_id = #{account_user.id}
            group by
              account_user_groups.account_user_id,
              data_controls.namespace,
              data_controls.key,
              data_controls.value,
              data_controls.operator
          ) as data_control_subquery
            on data_control_subquery.namespace = prefabs.namespace
            and (
              (data_control_subquery.operator = 'eq'
                AND (prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.') = data_control_subquery.value::jsonb)
              OR (data_control_subquery.operator = 'neq'
                AND (prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.') <> data_control_subquery.value::jsonb)
              OR (data_control_subquery.operator = 'lt'
                AND ((prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.'))::numeric < data_control_subquery.value::numeric)
              OR (data_control_subquery.operator = 'lte'
                AND ((prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.'))::numeric <= data_control_subquery.value::numeric)
              OR (data_control_subquery.operator = 'gt'
                AND ((prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.'))::numeric > data_control_subquery.value::numeric)
              OR (data_control_subquery.operator = 'gte'
                AND ((prefabs.data)#>regexp_split_to_array(data_control_subquery.key, '\\.'))::numeric >= data_control_subquery.value::numeric)
            )
        SQL
      )
      .joins(
        <<-SQL
          left join (
            select
              account_user_groups.account_user_id AS "account_user_id",
              namespace,
              min(access_controls.mode) as "access_mode"
            from
              access_controls
              left join account_user_groups
                  on access_controls.group_id = account_user_groups.group_id
            where account_user_groups.account_user_id = #{account_user.id}
            group by account_user_groups.account_user_id, namespace
          ) as access_control_subquery
            on access_control_subquery.namespace = prefabs.namespace
        SQL
      )
      .group('prefabs.id')
      .group('prefabs.namespace')
      .select('prefabs.id, prefabs.namespace')
      .having('min(coalesce(data_control_subquery.mode, access_control_subquery.access_mode)) > 0')
      .to_sql

    return scope
      .joins(
        <<-SQL
          inner join (#{inner_sql}) AS "control_scope"
            on prefabs.id = control_scope.id
              and prefabs.namespace = control_scope.namespace
        SQL
      )
  end
end
