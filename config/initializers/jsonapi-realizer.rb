module JSONAPI::Realizer::Adapter::ActiveRecord
  def paginate(scope, per, offset)
    scope.page(offset.to_i + 1).per(per)
  end
end
