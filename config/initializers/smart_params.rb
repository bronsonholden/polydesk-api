module SmartParams
  class Field
    Strict = SmartParams::Strict

    def all_params
      compounding_params
      sorting_params
      sparse_params
      filter_params
      pagination_params
    end

    def compounding_params
      field :include, type: Strict::String.constrained(min_size: 1).optional
    end

    def sorting_params
      field :sort, type: Strict::String.constrained(min_size: 1).optional
    end

    def sparse_params
      field :fields, type: Strict::Hash.optional
    end

    def filter_params
      field :filter, type: Strict::Hash.optional
    end

    def pagination_params
      field :page, type: Strict::Hash.optional.default { {offset: '0', limit: '25'} } do
        field :offset, type: Strict::String.optional.default { '0' }
        field :limit, type: Strict::String.optional.default { '25' }
      end
    end
  end
end
