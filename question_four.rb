require_relative "environment.rb"
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row| #iterates through the first CSV
  c = Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
  CSV.foreach("data/source2.csv", headers: true) do |row| #then iterates through the second CSV file
    if c.name == row["campaign"]
      c.object_type = row["object_type"] #adds the object type in the row if the new campaign's name matches the campaign row in the new CSV
    end 
  end
end


puts Campaign.cost_per_video_view #prints out the average cost per video view for the Campaign class.