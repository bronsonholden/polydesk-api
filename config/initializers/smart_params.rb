module SmartParams
  class Field
    Strict = SmartParams::Strict

    def all_params
      compounding_params
      sorting_params
      sparse_params
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

    def pagination_params
      field :page, type: Strict::Hash.optional do
        field :offset, type: Strict::String.optional
        field :limit, type: Strict::String.optional
      end
    end
  end
end
