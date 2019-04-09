class OptionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :value
  link :self, -> (option) {
    option.url
  }
end
