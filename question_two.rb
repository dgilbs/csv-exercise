require_relative "environment.rb"
require 'pry'


CSV.foreach("data/source1.csv", headers: true) do |row|
  c = Campaign.new(row.to_hash)
end

binding.pry

puts Campaign.conversions_by_initiative("plants")
