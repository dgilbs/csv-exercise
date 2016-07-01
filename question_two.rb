require_relative "environment.rb"
require 'pry'


CSV.foreach("data/source1.csv", headers: true) do |row| #iterates through the CSV
  Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
end

#at this point we have a campaign object for each row in the CSV
puts Campaign.conversions_by_initiative("plants") #will print the number of conversions of type x or y of all campaigns with the initiative "plants"
