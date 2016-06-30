require 'json'
require "require_all"

class Campaign

  attr_accessor :name, :date, :spend, :impressions, :actions

  @@all = []

  def initialize(hash)
    @name = hash["campaign"]
    @date = hash["date"]
    @spend = hash["spend"].to_f
    @impressions = hash["impressions"]
    @actions = JSON.parse(hash["actions"])
    @@all << self
  end

  def self.all_campaigns
    arr = self.all.collect{|campaign| campaign.name}
    arr.uniq
  end

  def self.all
    @@all 
  end

  def self.campaign_count
    self.all_campaigns.length
  end

  def name_elements
    self.name.split("_")
  end

  def initiative
    self.name_elements[0]
  end

  def audience
    self.name_elements[1]
  end

  def asset
    self.name_elements[2]
  end

  def self.all_assets
    arr = self.all.collect{|campaign| campaign.asset}
    arr.uniq
  end


  def self.all_audiences
    arr = self.all.collect{|campaign| campaign.audience}
    arr.uniq
  end


  def self.all_initiatives
    arr = self.all.collect{|campaign| campaign.initiative}
    arr.uniq
  end

  def x_or_y_conversions
    count = 0
    self.actions.each do |object|
      if object["action"] == "conversions"
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

  def x_or_y_views
    count = 0
    self.actions.each do |object|
      if object["action"] == "views"
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
        hash["conversions_per_spend"] = (hash["conversions"]/hash["total_spend"]).round(2)
        final.push(hash)
        counter2 += 1
      end
      counter1 += 1
    end
    final
  end

 def self.plant_conversions
  total = 0
  arr = self.all.select{|campaign| campaign.initiative == "plants"}
  arr.each do |campaign|
    total += campaign.x_or_y_conversions
  end
  total
 end

 def self.asset_audience_counter(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  arr.length
 end 

 def self.asset_audience_spend(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  spends = arr.collect{|campaign|campaign.spend}
  sum = 0.00
  spends.each do |number|
    sum += number
  end
  sum.round(2)
 end

 def self.asset_audience_conversions(audience, asset)
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset}
  conversions = arr.collect{|campaign|campaign.x_or_y_conversions}
  conversions.inject(0) { |sum, number| sum + number}
 end

 def self.lowest_combo_spend_per_conversion
  arr = self.asset_audience_combos.sort_by{|combo| combo["conversions_per_spend"] }
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