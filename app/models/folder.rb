class Folder < ApplicationRecord
  belongs_to :parent, class_name: 'Folder'
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id'
  validates :name, presence: true, format: {
    # Allow alphanumerals, spaces, and _ . - ( ) [ ]
    # Spaces and . may not be the first or last character
    with: /\A([A-Za-z0-9\-\(\)\[\]'_][A-Za-z0-9 \-\(\)\[\]'_\.][A-Za-z0-9\-\(\)\[\]'_]|[A-Za-z0-9\-\(\)\[\]\|'_]{1,2})\z/,
    message: 'may only contain alphanumerals, spaces, or the following: _ . - ( ) [ ] and may not start or end with a space or .'
  }
end
