
class ResourceQuery
  attr_reader :payload, :filter_applicator, :generate_applicator

  def initialize(payload)
    @payload = payload.deep_dup
    @filter_applicator = filter_applicator_class.new(self)
    @generate_applicator = generate_applicator_class.new(self)
  end

  def apply(scope)
    scope = apply_generate(scope)
    scope = apply_filter(scope)
    scope
  end

  protected

  def filter_applicator_class
    Applicators::Filter::ResourceFilterApplicator
  end

  def generate_applicator_class
    Applicators::Generate::ResourceGenerateApplicator
  end

  def column_name(table_alias, identifier)
    if identifier.start_with?("data.")
      path = identifier.split('.')[1..-1]
      "((#{table_alias}.data)\#>>'{#{path.join(',')}}')"
    else
      "(#{table_alias}.#{identifier})"
    end
  end

  def apply_filter(scope)
    filters = payload.fetch('filter', [])

    if filters.is_a?(String)
      filters = [filters]
    end

    filters.each { |filter|
      scope = filter_applicator.apply(scope, filter)
    }

    scope
  end

  def apply_generate(scope)
    generate = payload.fetch('generate', {})

    reserved_identifiers = scope.column_names
    generate.keys.each { |key|
      # Verify that no identifiers exactly match existing attributes.
      # Re-used identifiers will simply be overwritten, but we need to make
      # sure that attributes like namespace can't be replaced.
      if reserved_identifiers.include?(key)
        raise Polydesk::Errors::RestrictedGeneratedColumnIdentifier.new(key)
      end

      # Check that identifiers are using only alphanumerics and _, and
      # don't start with a number.
      if !key.match(/^[a-zA-Z_]+[a-zA-Z0-9_]*$/)
        raise Polydesk::Errors::InvalidGeneratedColumnIdentifier.new(key)
      end
    }

    generate.each { |key, value|
      scope, sql = generate_applicator.apply(scope, key, value)
    }

    scope
  end
end
