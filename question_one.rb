require_relative "environment.rb"
require 'json'
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row| #iterates through 
  Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
end

#at this point we have a campaign object for each row in the CSV
puts Campaign.campaign_count_in_month("February") #calls a method to print the number of unique campaigns for the month of February
