# Applies data and access controls, removing Prefabs from the given scope
# if A) there are zero "allow" controls the match the Prefab or B) there is at
# least one "deny" control that matches the prefab.
#
# This "scrubbing" process is done with a combination of a fairly simple
# inner join, and a WHERE clause.
class PrefabControlService
  attr_reader :account_user

  def initialize(account_user)
    @account_user = account_user
  end

  # Applies controls by using a subquery that, when inner joined to the
  # base scope, will exclude any rows that do not match at least one control.
  # This enforces whitelisting access to data. Any rows in the result set
  # must have a non-zero mode; otherwise there is at least one "deny" control
  # that applies to that Prefab, and so it is excluded by the following
  # WHERE clause.
  def apply(scope)
    scope
      .joins(
        <<-SQL
          inner join (
            select
              account_user_groups.account_user_id AS "account_user_id",
              namespace, min(access_controls.mode) as "access_mode"
              from access_controls
                left join account_user_groups
                  on access_controls.group_id = account_user_groups.group_id
              where account_user_groups.account_user_id = #{account_user.id}
              group by account_user_groups.account_user_id, namespace
          ) as access_control_subquery
            on access_control_subquery.namespace = prefabs.namespace
        SQL
      ).where('access_control_subquery.access_mode > 0')
  end
end
