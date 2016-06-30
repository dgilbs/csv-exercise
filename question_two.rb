require_relative "environment.rb"
require 'pry'


CSV.foreach("data/source1.csv", headers: true) do |row|
  camp = Campaign.new(row.to_hash)
end



puts Campaign.plant_conversions