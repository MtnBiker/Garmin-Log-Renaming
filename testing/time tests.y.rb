require 'rubygems'
require "date"
require "tzinfo"
require './lib/geonames.rb'

# MAYBE MAKE THIS A COUPLE OF METHODS 
# GOT CONFUSED BETWEEN THIS VERSION WHICH WAS .z and .y, so .z became .x or something

def latlon(line)
  #  Extracting lat and lon from trkpt line 
  # <trkpt lat="38.329948" lon="-119.636582"> # this shows format of the line with lat and lon
  line =~ /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/ # (\-?[\d\.]+) gets the sign and the digits
   # lat = $1,  lon = $2
  return alatlon=[$1,$2]
end

alation = []
datetime =  "2013-01-14T16:26:58Z" # will get this from gpx record
# datetime =  ["2013-01-14T16:26:58Z", "2013-09-20T03:38:42Z", "2013-07-01T15:45:00Z", "2013-10-15T13:39:57Z"]
# datetime =  [["2013-01-14T16:26:58Z",["33.812228" "-118.383842"]], ["2013-09-20T03:38:42Z",["44.826124", "15.656795"]], ["2013-07-01T15:45:00Z",["33.812149" "-118.383686"]], ["2013-10-15T13:39:57Z", ["41.497393" "-81.592296"]]]
# Represents CA ST, Croatia, CA DST, Ohio EDT
puts "datetime: #{datetime}"
tp = Date._parse(datetime) # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7
time = Time.gm(tp[:year],tp[:mon],tp[:mday],tp[:hour],tp[:min],tp[:sec]) # Time in Ruby sense (date and time)
puts "\ntime:     #{time}"
puts time.year
puts "\nyear: #{time.year}"
puts time.month

# Do this with api.timezone
# if Time.local(tp[:year],tp[:month],tp[:day]).isdst
#   isdst = "DST"
# else
#   isdst = "ST"
# end # Time.local

# alatlon = latlon([33.812228,-118.383842]) 
alation = ["33.812158", "-118.383703"] # Redondo
alation = ["35.5", "-75.5"] # 45 degrees east of Redondo
# puts "189. fx: #{fx}. ln: #{ln}. datetime: #{datetime}. Time.new(datetime) #{datetime}. "
puts "\nalatlon: #{alation}. alatlon[0]: #{alation[0]}\n"

# Timezone. From the coordinates find out what time zone the track is in and whether it's DST or not from dstOffset and 
# timezone = Geonames::WebService.timezone alatlon[0], alatlon[1]
api = GeoNames.new
timeZ = api.timezone(lat: alation[0], lng: alation[1])
puts "\ntimeZ: #{timeZ}."

# # Determine time zone stuff. Only accurate if determined the day of the file. Time isn't an input. In other words can't use GeoNames to find DST or ST.
# gmtOffset = timeZ["gmtOffset"]
# dstOffset  = timeZ["dstOffset"]
# if gmtOffset == dstOffset
#   isdst = "ST"
# else
#   isdst = "DST"
# end
# timezoneId = timeZ["timezoneId"]
# puts "gmtOffset: #{gmtOffset}. dstOffset: #{dstOffset}. isdst: #{isdst}."

# Using TZInfo to get time zone
#  All this requires knowing the time zone, so get from GeoNames

# tz = TZInfo::Timezone.get('America/New_York')
tz = TZInfo::Timezone.get(timeZ["timezoneId"]) # using timeZ which is the time zone for particular coordinates
puts "tz: #{tz}"

#  
# puts  "\nFor manually entered timedate"
# puts tz.utc_to_local(DateTime.new(2005,8,29,15,35,0)).to_s
# puts tz.local_to_utc(Time.utc(2005,8,29,15,35,0)).to_s
# puts tz.local_to_utc(Time.utc(2005,8,29,11,35,0)).to_s
# puts tz.utc_to_local(1125315300).to_s
# 
# Now need to get for the time of the track
puts "\nsome info for time: #{time}"
puts "tz.utc_to_local(DateTime.new(time.year, time.month, time.day, time.hour, time.min, time.sec)).to_s: #{tz.utc_to_local(DateTime.new(time.year, time.month, time.day, time.hour, time.min, time.sec)).to_s}"
puts "Using the timezone established by TZinfo. Hurrah. Not so sure. DOUBLE CHECK."

# Trying to avoid putting in the long thing below,but couldn't figure out how to make it work
# arrTime = [time.year, time.month, time.day, time.hour, time.min, time.sec]
# timeComma = arrTime.join(",")
# puts "\ntimeComma: #{timeComma}"
# timeLocal = tz.utc_to_local(DateTime.new(timeComma)) # This didn't work. Would be neater, must be a way

timeLocal = tz.utc_to_local(DateTime.new(time.year, time.month, time.day, time.hour, time.min, time.sec))
timePretty = time.strftime("%A, %B %d, %Y %I:%M%p %Z")
puts "\ntimePretty: #{timePretty}. But this is UTC and I want it local"

timePretty = timeLocal.strftime("%A, %B %d, %Y %I:%M%p")
puts "\ntimePretty: #{timePretty}. Using timeLocal. Will have to add time zone identifier manually"

tzi = tz.period_for_utc(Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec)).zone_identifier
timePretty = "#{timePretty} #{tzi}"
puts "\ntimePretty: #{timePretty}"
# puts tz.local_to_utc(Time.utc(2005,8,29,15,35,0)).to_s
# puts tz.local_to_utc(Time.utc(2005,8,29,11,35,0)).to_s
# puts tz.utc_to_local(1125315300).to_s



# period = tz.period_for_utc(Time.utc(2005,8,29,15,35,0))
# # period = TZInfo::Timezone.get('America/New_York').period_for_utc(Time.utc(2005,8,29,15,35,0))
# id = period.zone_identifier
# # id = TZInfo::Timezone.get('America/New_York').period_for_utc(Time.utc(2005,8,29,15,35,0)).zone_identifier
# puts "\nperiod: #{period}\ntz.period_for_utc(Time.utc(2005,8,29,15,35,0)) and then zone identifier: #{id}"

dst = tz.period_for_utc(Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec)).dst? # dst Daylight Savings Time
puts "dst: #{dst}" #  returns true or false and seems to work
