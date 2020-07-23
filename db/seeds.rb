# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'securerandom'

num_employees = 50000
num_jobs = 5000

employee_blueprint = Blueprint.create!(name: 'Employee', namespace: 'employees', schema: { type: 'object' }, view: { xs: {} })
job_blueprint = Blueprint.create!(name: 'Job', namespace: 'jobs', schema: { type: 'object' }, view: { xs: {} })

jobs = []

num_jobs.times do |i|
  puts "JOB #{i}"
  jobs << [
    i,
    [],
    job_blueprint.id,
    'jobs',
    {},
    {},
    {
      job_name: "JOB #{SecureRandom.hex}"
    }
  ]
end

employees = []
num_employees.times do |i|
  puts "EMPLOYEE #{i}"
  employees << [
    i,
    [],
    employee_blueprint.id,
    'employees',
    {},
    {},
    {
      first_name: "FIRST #{SecureRandom.hex}",
      last_name: "LAST #{SecureRandom.hex}",
      job: "jobs/#{rand(1..num_jobs)}"
    }
  ]
end

Prefab.import [ :id, :flat_data, :blueprint_id, :namespace, :schema, :view, :data ], jobs
Prefab.import [ :id, :flat_data, :blueprint_id, :namespace, :schema, :view, :data ], employees

# PrefabQuery.new({ 'generate' => { 'job_name' => 'lookup_s("data.job", "data.job_name")' } }, inner_scope: Prefab.all).apply(Prefab.partition_key_eq('employees'))
# PrefabQuery.new({ 'generate' => { 'job_name' => 'lookup_s("data.job", "data.job_name")' } }, inner_scope: Prefab.all).apply(Prefab.partition_key_eq('employees')).map { |e| "#{e.data['first_name']} - #{e.job_name}" }
# PrefabQuery.new({ 'generate' => { 'employee_count' => 'referent_count_distinct("employees", "data.job", "id")' } }, inner_scope: Prefab.all).apply(Prefab.partition_key_eq('jobs'))
# PrefabQuery.new({ 'generate' => { 'employee_count' => 'referent_count_distinct("employees", "data.job", "id")' } }, inner_scope: Prefab.all).apply(Prefab.partition_key_eq('jobs')).to_a.map { |j| "#{j.data['job_name']} - #{j.employee_count}" }

#
# blueprint = Blueprint.all.first
# if blueprint.nil?
#   blueprint = Blueprint.create(name: 'Blueprint', namespace: 'prefabs', schema: { type: 'object' }, view: { xs: {} })
# end
# n = 500000
# # 10000000
# first = Prefab.all.size + 1
# last = first + n
# refs = (first...last).to_a.shuffle
# n.times do |i|
#   puts "Prefab ##{i + first}"
#   Prefab.new(blueprint: blueprint, data: {
#     prefab: "prefabs/#{refs[i]}",
#     value: SecureRandom.hex
#   })
# end

# expr = 'lookup_s("data.prefab", "data.value")'
# generate = { 'generate' => { 'lookup_value' => expr } }
