class DataControl < ApplicationRecord
  # TODO: Validate key matches ^[a-zA-Z]+(\.[a-zA-Z]+)*$
  belongs_to :group
end
