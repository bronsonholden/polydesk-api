# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'securerandom'

blueprint = Blueprint.all.first
if blueprint.nil?
  blueprint = Blueprint.create(name: 'Blueprint', namespace: 'prefabs', schema: { type: 'object' }, view: { xs: {} })
end
n = 500000
# 10000000
first = Prefab.all.size + 1
last = first + n
refs = (first...last).to_a.shuffle
n.times do |i|
  puts "Prefab ##{i + first}"
  Prefab.create!(blueprint: blueprint, data: {
    prefab: "prefabs/#{refs[i]}",
    value: SecureRandom.hex
  })
end

# expr = 'lookup_s("data.prefab", "data.value")'
# generate = { 'generate' => { 'lookup_value' => expr } }
