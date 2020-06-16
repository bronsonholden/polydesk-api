module JSONAPI::Realizer::Adapter::ActiveRecord
  def paginate(scope, per, offset)
    scope.limit(per.to_i).offset(per.to_i * offset.to_i)
  end
end
