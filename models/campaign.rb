require 'json'
require "require_all"

class Campaign

  attr_accessor :name, :date, :spend, :impressions, :actions

  @@all = [] #creates a class variable to keep track of all instances

  def initialize(hash)
    @name = hash["campaign"] #decided to change it to "name" since this is the campaign class
    date_elements = hash["date"].split("/") #date is being passed in as a string, need this array to create the Date object in the next line
    @date = Date.new(date_elements[2].to_i + 2000, date_elements[0].to_i, date_elements[1].to_i) #added 2000 to year since the program was considering it as the year 15; this creates the date object
    @spend = hash["spend"].to_f #use .to_f to make sure spend comes in as a float instead of a string
    @impressions = hash["impressions"].to_i #need it as an integer for counting purposes later
    @actions = JSON.parse(hash["actions"])#ensures that each action comes in as an array instead of a string
    @@all << self #shovels it into the all array
  end

  def self.all_campaigns #this method will collect all the unique campaign names
    arr = self.all.collect{|campaign| campaign.name} #this gives an array with each campaigns name and includes duplicates
    arr.uniq #calls .uniq on the existing array to remove duplicates and returns that array
  end

  def self.campaigns_in_month(month) #returns all the campaigns run in a given month
    month_num = Date::MONTHNAMES.index(month) #converts the month string into a integer for comparison purposes later
    self.all.select do |campaign|
      campaign.date.month == month_num #selects all campaigns whose month is the same as the one passed into the argument
    end
  end

  def self.campaign_count_in_month(month) #returns the number of campaigns run in a single month
    self.campaigns_in_month(month).count
  end

  def self.campaign_types_in_month(month) #returns a list of unique initiative-asset-audience combinations for a given month
    all = self.campaigns_in_month(month)
    array = all.map{|campaign| campaign.name}
    array.uniq
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
        if object["x"] && object["y"]#deals with fringe cases where there might be views of type x and of type y
          count += object["x"]
          count += object["y"] #adds them both in
        elsif object["y"]
          count += object["y"] #adds views of type y if they exist
        elsif object["x"]
          count += object["x"] #adds views of type x if they exist
        end
      end
    end
    count
  end


  def self.asset_audience_combos #this method will an array of hashes with data on each asset-audience combination
    counter1 = 0 #sets a counter for the first while loop
    final = [] #creates the array that we will push each hash into
    while counter1 < self.all_audiences.length #begins the first of two loops--this will be going through the audience list
      counter2 = 0 #sets a counter for the second while loop
      while counter2 < self.all_assets.length #this loop will take which audience the first loop is on and pair it with each asset to produce all combos
        hash = {} #creates the hash we are going to push into the array
        hash["audience"] = self.all_audiences[counter1] #says what audience we're on in the loop
        hash["asset"] = self.all_assets[counter2] #says what asset we're on in the lopp
        hash["counter"] = self.asset_audience_counter(self.all_audiences[counter1], self.all_assets[counter2]) #counts how many campaigns have this combinations--method below
        hash["conversions"] = self.asset_audience_conversions(self.all_audiences[counter1], self.all_assets[counter2]) #counts the conversions of type x and type y from campaigns of this combination--method below
        hash["total_spend"] = self.asset_audience_spend(self.all_audiences[counter1], self.all_assets[counter2]) #counts the total spend across all campaigns with the current combination--method below
        hash["impressions"] = self.asset_audience_impressions(self.all_audiences[counter1], self.all_assets[counter2]) #counts the total impressions of all campaigns of this combination--method below
        hash["average_conversion_cost"] = (hash["total_spend"]/hash["conversions"]).round(2) #converts the average cost of a conversion for this combination
        hash["cpm"] = self.asset_audience_cpm(self.all_audiences[counter1], self.all_assets[counter2]) #converts the cpm for this combination--method below
        final.push(hash) #pushes the hash into the array
        counter2 += 1 #increments counter
      end
      counter1 += 1 #increments counter
    end
    final returns the array
  end


 def self.conversions_by_initiative(initiative) #returns the number of conversions of type x or y for a given initiative
  total = 0 #sets a counter
  arr = self.all.select{|campaign| campaign.initiative == initiative} #picks out all campaigns with that initiative
  arr.each do |campaign| #iterates through the array of campaigs
    total += campaign.x_or_y_conversions #adds in the number of x or y conversions for each one
  end
  total #returns the coutner
 end

 def self.asset_audience_cpm(audience, asset) #returns the CPM (spend/impressions * 1000) for each asset-audience combination
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset} #picks all campaigns with that asset-audience combination
  impressions  = arr.collect{|campaign|campaign.impressions} #creates an array with each campaign's impressions
  total_impressions = impressions.inject(0) { |sum, number| sum + number} #adds all impressions together
  total_spend = self.asset_audience_spend(audience, asset) #brings in the total spend fo campaigns of this combination
  spend_per_impressions = total_spend/total_impressions.to_f #divides the spend by impressions
  spend_per_impressions * 1000 #returns the number that reflects to CPM
 end

 def self.asset_audience_counter(audience, asset) #returns how many campaigns have an asset-audience combination
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset} #makes an array of all campaigns with this combination
  arr.length #returns the number of items in that array
 end 

 def self.asset_audience_spend(audience, asset) #returns the total spend for all campaigns with a given asset-audience combination
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset} #picks the campaigns with that combination
  spends = arr.collect{|campaign|campaign.spend} #collects all of their spends and puts it into an array
  sum = 0 #sets a counter
  spends.each do |number|
    sum += number #adds each spend into the counter
  end
  sum.round(2) #returns the counter and rounds it
 end

 def self.asset_audience_conversions(audience, asset) #returns a count of conversions for an asset-audience combination
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset} #picks the campaigns with that combination
  conversions = arr.collect{|campaign|campaign.x_or_y_conversions} #creates an array of each of those campaign's conversions of type x and y
  conversions.inject(0) { |sum, number| sum + number} #returns the sum of all those numbers in the array
 end

 def self.asset_audience_impressions(audience, asset) #returns a count of impressions for an asset-audience combination
  arr = self.all.select{|campaign| campaign.audience == audience && campaign.asset==asset} #picks the campaigns with that combination
  impressions = arr.collect{|campaign|campaign.impressions}#creates an array of each of those campaign's impressions of type x and y
  impressions.inject(0){|sum, number| sum + number}#returns the sum of all those numbers in the array
 end

 def self.lowest_combo_conversion_cost #returns the asset-audience combo with the lowest average conversion cost
  arr = self.asset_audience_combos.sort_by{|combo| combo["average_conversion_cost"] } #sorts the array of all combos by their average conversion cost
  arr.first #returns the first item in the array
 end

 def self.lowest_asset_audience_cpm_combo #returns the asset-audience combination with the lowest CPM
  arr = self.asset_audience_combos.sort_by{|combo| combo["cpm"] } #sorts the array of all combos by their CPM
  arr.first #returns the first item in the array
 end

 def object_type=(type) #a setter method to give a single campaign an object type
  @type = type
 end

 def object_type #a getter method to return the object type of a single campaign
  @type
 end

 def self.videos #returns all campaigns with the object type of video
  self.all.select do |campaign|
    campaign.object_type == "video"
  end
 end

 def self.photos #returns all campaigns with the object type of photo
  self.all.select do |campaign|
    campaign.object_type == "photo"
  end
 end

 def self.total_video_spend #returns the total spend of all campaigns with the object type of video
  spends = self.videos.collect{|video| video.spend} #creates an array of each video's spend
  sum = 0.00 #sets a counter
  spends.each do |number|
    sum += number #iterates through the array and adds each item to the counter
  end
  sum.round(2) #returns the rounded counter
 end

 def self.no_object_type #returns an array of all campaigns with no object type
  self.all.select{|campaign| campaign.object_type.nil?}
 end

 def self.total_video_views #returns the total amount of views of type x and y across all videos
  views = self.videos.map {|video| video.x_or_y_views} #creates an array with each video's view count
  views.inject(0){|sum, x| sum + x} #calculates and returns the sum of the above array
 end

 def self.cost_per_video_view #caluclates the average cost of a video across the whole class
  total_cost = self.total_video_spend
  total_views = self.total_video_views.to_f
  (total_cost/total_views).round(2)
 end

end