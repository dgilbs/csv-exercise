require_relative "environment.rb"
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row|
  Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
end

lowest_ratio = Campaign.lowest_combo_spend_per_conversion

puts lowest_ratio




