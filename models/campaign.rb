require 'json'
require "require_all"

class Campaign

  attr_accessor :name, :date, :spend, :impressions, :actions

  @@all = [] #creates a class variable to keep track of all instances

  def initialize(hash)
    @name = hash["campaign"]
    @date = hash["date"]
    @spend = hash["spend"].to_f #use .to_f to make sure spend comes in as a float instead of a string
    @impressions = hash["impressions"].to_i
    @actions = JSON.parse(hash["actions"])#ensures that each action comes in as an array instead of a string
    @@all << self #
  end

  def self.all_campaigns #this method will collect all the unique campaign names
    arr = self.all.collect{|campaign| campaign.name} #this gives an array with each campaigns name and includes duplicates
    arr.uniq #calls .uniq on the existing array to remove duplicates and returns that array
  end

  def self.all
    @@all 
  end

  def self.campaign_count
    self.all_campaigns.length #returns the number of campaigns returned in "all_campaigns"
  end

  def name_elements #a method that will split up the campaign name 
    self.name.split("_")
  end

  def initiative
    self.name_elements[0] #initiative is the first element in the campaign's name and will be the first item in the name_elements array
  end

  def audience
    self.name_elements[1]#audience is the second element in the campaign's name and will be the second item in the name_elements array
  end

  def asset
    self.name_elements[2] #asset is the third element in the campaign's name and will be the third item in the name_elements array
  end

  def self.all_assets #will return a unique list of all assets
    arr = self.all.collect{|campaign| campaign.asset}
    arr.uniq
  end


  def self.all_audiences #will return a unique list of all audiences
    arr = self.all.collect{|campaign| campaign.audience}
    arr.uniq
  end


  def self.all_initiatives #will return a unique list of all initiatives
    arr = self.all.collect{|campaign| campaign.initiative}
    arr.uniq
  end

  def x_or_y_conversions #will return the number of conversions of type x or y for any instance of the campaign class
    count = 0 #sets a counter
    self.actions.each do |object| #iterates through the campaign's actions
      if object["action"] == "conversions" #makes sure only the action type of conversions are being done
        if object["x"] && object["y"] #deals with fringe cases where there might be conversions of type x and of type y
          count += object["x"] 
          count += object["y"] #adds them both in
        elsif object["y"] 
          count += object["y"] #adds conversions of type y  if it exists
        elsif object["x"]
          count += object["x"] #adds conversions of type x if it exists
        end
      end
    end
    count #returns the final count
  end

  def x_or_y_views # will return the number of views of type x or y for any instance of the campaign class
    count = 0 #sets a counter
    self.actions.each do |object| #iterates through the campaign's actions
      if object["action"] == "views" #only takes into consideration the views
        if object["x"] && object["y"]
          count += object["x"]
          count += object["y"]
        elsif object["y"]
          count += object["y"]
        elsif object["x"]
          count += object["x"]
        end
      end
    end
    count
  end


  def self.asset_audience_combos
    counter1 = 0
    final = []
    while counter1 < self.all_audiences.length
      counter2 = 0
      string = self.all_audiences[counter1] + "-"
      while counter2 < self.all_assets.length
        hash = {}
        hash["audience"] = self.all_audiences[counter1]
        hash["asset"] = self.all_assets[counter2]
        hash["counter"] = self.asset_audience_counter(self.all_audiences[counter1], self.all_assets[counter2])
        hash["conversions"] = self.asset_audience_conversions(self.all_audiences[counter1], self.all_assets[counter2])
        hash["total_spend"] = self.asset_audience_spend(self.all_audiences[counter1], self.all_assets[counter2])
        hash["impressions"] = self.asset_audience_impressions(self.all_audiences[counter1], self.all_assets[counter2])
        hash["conversions_per_spend"] = (hash["conversions"]/hash["total_spend"]).round(2)
        hash["cpm"] = self.asset_audience_cpm(self.all_audiences[counter1], self.all_assets[counter2])
        final.push(hash)
        counter2 += 1
      end
      counter1 += 1
    end
    final
  end


 def self.conversions_by_initiative(initiative)
  total = 0
  arr = self.all.select{|campaign| campaign.initiative == initiative}
  arr.each do |campaign|
    total += campaign.x_or_y_conversions
  end
  total
 end

 def self.asset_audience_cpm(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  impressions  = arr.collect{|campaign|campaign.impressions}
  total_impressions = impressions.inject(0) { |sum, number| sum + number}
  total_spend = self.asset_audience_spend(audience, asset)
  spend_per_impressions = total_spend/total_impressions.to_f
  spend_per_impressions * 1000
 end

 def self.asset_audience_counter(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  arr.length
 end 

 def self.asset_audience_spend(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  spends = arr.collect{|campaign|campaign.spend}
  binding.pry
  sum = 0
  spends.each do |number|
    sum += number.round(2)
  end
  sum
 end

 def self.asset_audience_conversions(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  conversions = arr.collect{|campaign|campaign.x_or_y_conversions}
  conversions.inject(0) { |sum, number| sum + number}
 end

 def self.asset_audience_impressions(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  impressions = arr.collect{|campaign|campaign.impressions}
  impressions.inject(0){|sum, number| sum + number}
 end

 def self.lowest_combo_spend_per_conversion
  arr = self.asset_audience_combos.sort_by{|combo| combo["conversions_per_spend"] }
  arr.first
 end

 def self.lowest_asset_audience_cpm_combo
  arr = self.asset_audience_combos.sort_by{|combo| combo["cpm"] }
  arr.first
 end

 def object_type=(type)
  @type = type
 end

 def object_type
  @type
 end

 def self.videos
  self.all.select do |campaign|
    campaign.object_type == "video"
  end
 end

 def self.photos
  self.all.select do |campaign|
    campaign.object_type == "photo"
  end
 end

 def self.total_video_spend
  spends = self.videos.collect{|video| video.spend}
  sum = 0.00
  spends.each do |number|
    sum += number
  end
  sum.round(2)
 end

 def self.no_object_type
  self.all.select{|campaign| campaign.object_type.nil?}
 end

 def self.total_video_views
  views = self.videos.map {|video| video.x_or_y_views}
  views.inject(0){|sum, x| sum + x}
 end

 def self.cost_per_video_view
  total_cost = self.total_video_spend
  total_views = self.total_video_views.to_f
  (total_cost/total_views).round(2)
 end

end