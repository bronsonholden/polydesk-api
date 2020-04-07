class PrefabQuery < ResourceQuery
  attr_reader :inner_scope

  def initialize(query, inner_scope: Prefab.all)
    @inner_scope = inner_scope
    super(query)
    @generate_applicator = generate_applicator_class.new(self, inner_scope: inner_scope)

  end

  protected

  def filter_applicator_class
    Applicators::Filter::PrefabFilterApplicator
  end

  def generate_applicator_class
    Applicators::Generate::PrefabGenerateApplicator
  end
end
