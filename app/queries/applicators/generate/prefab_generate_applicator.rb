# Extends the base applicator to provide functions for lookups using
# Prefab relationships.
#
#    ?generate[job_title]=lookup_s("data.job", "data.title")
#
# The above matches a Prefab with the UID stored in the "job" property and
# returns the value at "job_title" on the matched Prefab (as a string).
module Applicators::Generate
  class PrefabGenerateApplicator < ResourceGenerateApplicator
    protected

    def apply_function(scope, identifier, ast)
      case ast.name
      when 'lookup_s'
        apply_function_lookup(scope, 'text', identifier, ast)
      when 'lookup_i'
        apply_function_lookup(scope, 'integer', identifier, ast)
      when 'lookup_f'
        apply_function_lookup(scope, 'float', identifier, ast)
      when 'lookup_b'
        apply_function_lookup(scope, 'boolean', identifier, ast)
      else
        super
      end
    end

    # Apply a lookup join to the given scope
    #   - scope: The scope to apply the join to
    #   - identifier: Generated column identifier
    #   - cast: What type to cast the result as (unused)
    #   - local: Alias for the local data property that holds the reference to
    #            the remote prefab.
    #   - remote: Data key path for the value to be returned from the lookup.
    #
    # Returns the modified scope and the column identifier for the value
    # returned by the lookup.
    def apply_lookup(scope, identifier, cast, local, remote)
      remote_table_alias = "lookup#{next_lookup_id}___#{remote.gsub('.', '__')}"
      remote_uid = "(#{remote_table_alias}.namespace || '/' || #{remote_table_alias}.tag)"
      scope = scope.joins(
        <<-SQL
          left join prefabs as #{remote_table_alias}
          on (#{local}::text) = #{remote_uid}
        SQL
        # and json_extract_path_text(#{remote_table_alias}.data::json, #{remote_table_alias}.namespace, 'inner') = 'prefabs'
      )
      return scope, "(#{column_name(scope, remote_table_alias, remote)}::#{cast})"
    end

    # Applies a lookup join to the given scope, returning the result converted
    # to the type provided by the cast argument.
    def apply_function_lookup(scope, cast, identifier, ast)
      local_arg, remote_arg = ast.children

      # The following 2 if-else blocks retrieve the local and remote aliases
      # to insert into the query. If the local and remote aliases are specified
      # using literals, there's a potential for SQL injection since they are
      # inserted directly into the query as given. Any disallowed characters
      # will raise a generator argument error. Non-lookup functions and
      # operators expressions are already converted into SQL expressions that
      # don't need scrubbing. When another lookup is passed as an argument,
      # it is inserted as the resulting column alias, and so doesn't need to
      # be scrubbed.

      if !local_arg.is_a?(Keisan::AST::Literal)
        scope, local = apply_ast(scope, identifier, local_arg)
      else
        if !local_arg.value.match(/^[-_.a-zA-Z0-9]+$/)
          raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 0 for #{ast.name}() is a literal with disallowed characters")
        end
        local = column_name(scope, 'prefabs', local_arg.value)
        if !local.is_a?(String)
          raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 0 for #{ast.name}() must be a string")
        end
      end

      if !remote_arg.is_a?(Keisan::AST::Literal)
        scope, remote = apply_ast(scope, identifier, remote_arg)
      else
        if !remote_arg.value.match(/^[-_.a-zA-Z0-9]+$/)
          raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 1 for #{ast.name}() is a literal with disallowed characters")
        end
        remote = remote_arg.value
        if !remote.is_a?(String)
          raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 1 for #{ast.name}() must be a string")
        end
      end

      apply_lookup(scope, identifier, cast, local, remote)
    end
  end
end
