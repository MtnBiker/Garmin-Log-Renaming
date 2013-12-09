require 'rubygems'
require "date"
require "tzinfo"
require './lib/geonames.rb'

# MAYBE MAKE THIS A COUPLE OF METHODS 
# .w to look at alternates to tz.utc_to_local 

def latlon(line)
  #  Extracting lat and lon from trkpt line 
  # <trkpt lat="38.329948" lon="-119.636582"> # this shows format of the line with lat and lon
  line =~ /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/ # (\-?[\d\.]+) gets the sign and the digits
   # lat = $1,  lon = $2
  return alatlon=[$1,$2]
end
i = 0
arrDatetime =  [["2013-01-14T16:26:58Z",["33.812228", "-118.383842"]], ["2013-09-20T03:38:42Z",["44.826124", "15.656795"]], ["2013-07-01T15:45:00Z",["33.812149", "-118.383686"]], ["2013-10-15T13:39:57Z", ["41.497393", "-81.592296"]], ["2010-10-20T13:23:55Z", ["27.797626", "87.126475"]]]
# Represents CA ST, Croatia, CA DST, Ohio EDT, Nepal
while i < 5
  alation = []
  # Note there is my variable myDatetime[i} and a method DateTime FIX
  # myDatetime =  "2013-01-14T16:26:58Z" # will get this from gpx record
  # myDatetime =  ["2013-01-14T16:26:58Z", "2013-09-20T03:38:42Z", "2013-07-01T15:45:00Z", "2013-10-15T13:39:57Z"]
  # Represents CA ST, Croatia, CA DST, Ohio EDT
  puts "25. arrDatetime[#{i}]: #{arrDatetime[i]}"
  myDatetime = arrDatetime[i][0]
  alation = arrDatetime[i][1]
  puts "28. myDatetime: #{myDatetime}."
  tp = Date._parse(myDatetime) # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7
  timeUTC = Time.gm(tp[:year],tp[:mon],tp[:mday],tp[:hour],tp[:min],tp[:sec]) # Time in Ruby sense (date and time)

  # puts "189. fx: #{fx}. ln: #{ln}. myDatetime[i}: #{myDatetime[i}}. Time.new(myDatetime[i}) #{myDatetime[i}}. "
  puts "\nalatlon: #{alation}. alatlon[0]: #{alation[0]}\n"
  # Timezone. From the coordinates find out what time zone the track is in and whether it's DST or not from dstOffset and 
  # timezone = Geonames::WebService.timezone alatlon[0], alatlon[1]
  api = GeoNames.new
  puts "timeZ IS ONLY GETTING THE TIMEZONE FOR COORDINATES, BUT OTHER INFORMATION NOT FOR **MY DATE** OF INTEREST BUT FOR **CURRENT** TIME
  # IN OTHER WORDS I still have to determine daylight savings time some other way"
  timeZ = api.timezone(lat: alation[0], lng: alation[1])
  puts "\ntimeZ: #{timeZ}."

  # Determine time zone stuff. Only accurate if determined the day of the file. Time isn't an input. In other words can't use GeoNames to find DST or ST.
  # gmtOffset = timeZ["gmtOffset"]
  # dstOffset  = timeZ["dstOffset"]
  # if gmtOffset == dstOffset
  #   isdst = "ST"
  # else
  #   isdst = "DST"
  # end
  # timezoneId = timeZ["timezoneId"]
  # puts "49. gmtOffset: #{gmtOffset}. dstOffset: #{dstOffset}. isdst: #{isdst}."

  # Using TZInfo to get time zone
  #  All this requires knowing the time zone, so get from GeoNames

  # tz = TZInfo::Timezone.get('America/New_York')
  tz = TZInfo::Timezone.get(timeZ["timezoneId"]) # using timeZ which is the time zone for particular coordinates
  # puts "56. tz:   #{tz}"
#   puts "57. timeUTC: #{timeZ["time"]}"
  tzi = tz.period_for_utc(Time.utc(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).zone_identifier
#   # tzn = TZInfo::Timezone.get(timeZ["dstOffset"]) # time zone local numerically
#   tzn =  timeZ["dstOffset"] # what is different about this than timezoneID
 puts "63. tzi: #{tzi}"

  #  
  # puts  "\nFor manually entered timedate"
  # puts tz.utc_to_local(DateTime.new(2005,8,29,15,35,0)).to_s
  # puts tz.local_to_utc(Time.utc(2005,8,29,15,35,0)).to_s
  # puts tz.local_to_utc(Time.utc(2005,8,29,11,35,0)).to_s
  # puts tz.utc_to_local(1125315300).to_s
  # 
  # Now need to get for the time of the track
  puts "\nsome info for timeUTC: #{timeUTC}"
  puts "tz.utc_to_local(DateTime.new(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).to_s: #{tz.utc_to_local(DateTime.new(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).to_s}"
  puts "Using the timezone established by TZinfo. Works, although seems a bit crude. CAN I FIND AWAY TO HAVE TIME ZONE CORRECT WITH THE INTIAL  timePretty"

  # Trying to avoid putting in the long thing below,but couldn't figure out how to make it work
  # arrTime = [timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec]
  # timeComma = arrTime.join(",")
  # puts "\ntimeComma: #{timeComma}"
  # timeLocal = tz.utc_to_local(DateTime.new(timeComma)) # This didn't work. Would be neater, must be a way
  
  # Unfortunately doesn't transform to the time zone, only puts in whateve you put in. The example from http://www.ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/DateTime.html had errors
  # puts "yet another test"
#   myDatetimeExp = [timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec,-7].join(" ")
#   puts "81. myDatetimeExp: #{myDatetimeExp}."
#   puts "82. #{DateTime.strptime('2001 5 6 4 5 6 +7', '%Y %m %d %H %M %S %z')}"
#                             # => #<DateTime:  2001-05-06T04:05:06+07:00 ...> Doesn't change the time zone, just puts in whatever you put, i.e, doesn't assume UTC
  
  timeLocal = tz.utc_to_local(DateTime.new(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)) # should be tzn, but testing with -7
  puts "timeLocal: #{timeLocal}."
  timePretty = timeUTC.strftime("%A, %B %d, %Y %I:%M%p %Z")
  puts "\n93. timePretty: #{timePretty}. But this is UTC and I want it local. with tzn"

  timePretty = timeLocal.strftime("%A, %B %d, %Y %I:%M%p")
  puts "\n96. timePretty: #{timePretty}. Using timeLocal. Will have to add time zone identifier manually"

  tzi = tz.period_for_utc(Time.utc(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).zone_identifier
  timePretty = "#{timePretty} #{tzi}"
  puts "\n100 timePretty: #{timePretty}"
  # puts tz.local_to_utc(Time.utc(2005,8,29,15,35,0)).to_s
  # puts tz.local_to_utc(Time.utc(2005,8,29,11,35,0)).to_s
  # puts tz.utc_to_local(1125315300).to_s



  dst = tz.period_for_utc(Time.utc(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).dst? # dst Daylight Savings Time
  puts "dst: #{dst}" #  returns true or false and seems to work
  i +=1
  puts "\n==========================\n"
end