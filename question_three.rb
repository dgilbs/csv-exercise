require_relative "environment.rb"
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row|#iterates through the CSV
  Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
end

#at this point we have a campaign object for each row in the CSV
puts Campaign.lowest_combo_conversion_cost #will return a hash for the asset-audience combo with the lowest average conversion cost





