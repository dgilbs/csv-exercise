require_relative "environment.rb"
require 'pry'


CSV.foreach("data/source1.csv", headers: true) do |row|
  camp = Campaign.new(row.to_hash)
end

Campaign.asset_audience_spend("cow", "jungle")

puts Campaign.conversions_by_initiative("plants")
