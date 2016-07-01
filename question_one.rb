require_relative "environment.rb"
require 'json'
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row|
  Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
end

puts Campaign.campaign_count_in_month("February") 
