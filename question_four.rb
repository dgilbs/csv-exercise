require_relative "environment.rb"
require 'pry'

CSV.foreach("data/source1.csv", headers: true) do |row|
  c = Campaign.new(row.to_hash) #this creates a new campaign from the given row of the CSV
  CSV.foreach("data/source2.csv", headers: true) do |row|
    if c.name == row["campaign"]
      c.object_type = row["object_type"]
    end 
  end
end

puts Campaign.cost_per_video_view