class PrefabQuery < ResourceQuery
  protected

  def filter_applicator_class
    Applicators::Filter::PrefabFilterApplicator
  end

  def generate_applicator_class
    Applicators::Generate::PrefabGenerateApplicator
  end
end
