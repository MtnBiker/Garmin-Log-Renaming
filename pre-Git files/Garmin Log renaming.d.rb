#!/usr/bin/env ruby
require 'rubygems'
require "date"
# require 'geonames'
require 'find'
require 'fileutils'
# require 'geocoder' # try when figure out how to add gems to iMac
# require 'Appscript' # what is this being used for?
require './lib/geonames.rb'

# require '/Users/gscar1/Dropbox/scriptsEtc/Garmin Log renaming/sdefToRBAppscriptModule.rb' # nokogiri requires Ruby version >= 1.9.2.

# AND find the time zone using coordinates. Done, ONLY SEEMS TO WORK IF DST IS THE SAME AS NOW. Also something weird about Santiago done in June
# Could check if date processing is close to date of file because of da
#  Also need to deal with whatever creates errors with the web services. Make more robust or give better error messages. And maybe try again.
=begin
  TODO fix time zone error. Shows -7 during standard time in Calif.  Not seeing this now 2013.01.07. Maybe wait for daylight time to see if there is a problem
=end
# SEE LINE 81 AND TRY TO FIX SO GET MORE INFORMATION
# .d converted geoname.rb which needs 1.9 which also meant some updating since parsedate was gone.
# .e added baseFolderGPX
# .f added ejecting of Garmin WON'T WORK UNTIL UPGRADE SCRIPT TO USE  Ruby version >= 1.9.2. AND THEN CAN TURN ON LAST REQUIRE AND LINES AT END 
# .g added processing of files from MotionX on iPhone
# .h create .TEMP. for files created on the day of download (they may be incomplete because of activity after the download). And move old TEMP files into a folder
# .i  copy original files from Garmin to computer. Added a folder to hard drive to handle the erroneous 1999 file that keeps showing up.
# .j process files from Garmin seems to working correctly
# .k stop processing when reach a file that's already been processed as indicated by the revised file existing. Better if it skipped existing files immediately, but maybe will have to change the script logic.
# ##### NEED TO MAKE SURE IF STALLS WILL FIND UNPROCESSED FILES. Reversing won't work
# .l process a whole folder: cycle through the folder
# .m minor cleanup before proceeding with .l. Seems to work O
# .n works fine. Going to add process a whole folder to do past files before tackling Folder Action

#  must be changed every year.
# baseFolderGPX = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/" # for gpx files
baseFolderGPX = "/Users/gscar/Dropbox/   Garmin gpx daily logs/" # for gpx files
folderDownload = baseFolderGPX + "2013 Download/"
folderMassaged = baseFolderGPX + "2013 Massaged/"
folderOnGarmin = "/Volumes/GARMIN/" # NEED TO COMBINE with copy files over

# oldTEMPfiles = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/old TEMP files/" # for files created on day of download which may not be complete
oldTEMPfiles = baseFolderGPX + "old TEMP files/" # for files created on day of download which may not be complete
# 
# If Garmin mounted, process from Garmin, otherwise from folderDownload (presumably manually copied over)
def latlon(line)
  #  Extracting lat and lon from trkpt line 
  # <trkpt lat="38.329948" lon="-119.636582"> # this shows format of the line with lat and lon
  line =~ /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/ # (\-?[\d\.]+) gets the sign and the digits
   # lat = $1,  lon = $2
  return alatlon=[$1,$2]
end

# Note that there are other geo services available as of 2013 in Ruby. For example http://www.rubygeocoder.com.
def loc(arr)
  # location = "If you're seeing this sentence, Geocoder isn't set up. Needs to be put in two places" # used with Geocoder which isn't being used with the current version
  # puts "54. #{arr}"
  # places_nearby = Geonames::WebService.find_nearby_place_name arr[0], arr[1] # used to work with geonames gem
  api = GeoNames.new
  # places_nearby = api.ocean(lat: 0, lng: 0)
#   puts "56. places_nearby: #{places_nearby}. "
#   puts "57. places_nearby.first.name: #{places_nearby['name']}"
#   puts "57. places_nearby.first.name: #{places_nearby.first.name}, places_nearby.first.country_name: #{places_nearby.first.country_name}"
  # puts "Coordinates input #{arr[0]}, #{arr[1]}"
  # location = Geocoder.search("#{arr[0]}, #{arr[1]}")
  # puts "location from Geocoder: #{location}" # if geocoder loaded. If gets good info, maybe change
  # puts "api.places_nearby['name']: #{api.places_nearby['name']}. api.country_code['countryName']: #{api.country_code['countryName']}"
  latIn = arr[0]
  longIN = arr[1]
  # puts "\n70: #{latIn}, #{longIN}\n"
  countryCode = api.country_code(lat: latIn, lng: longIN)
  # puts "\n72. countryCode: #{countryCode} \n countryCode['countryCode']: #{countryCode['countryCode']}"
  if countryCode['countryCode'] === "US"
    # neighborhood only works in the US and is supplied by Zillow
    neigh = api.neighbourhood(lat: latIn, lng: longIN)
    puts "\n74. For #{latIn}, #{longIN}: neigh: #{neigh}" # "/n #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}\n" 
    #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}"
    if neigh == nil
      puts "77. Data not available for this location from Zillow. lat, long: #{latIn}, #{longIN}\n   ########### Should find a better source than country_code}" # Should write a work
      return "#{countryCode['name']}, #{countryCode['adminName1']} #{countryCode['countryName']}" # doesn't give much information
      # api.find_nearby should give more information, but I can't figure out how to parse the hash. Could do it, but should be easier
      # api.find_nearby_wikipedia(latIn longIn) should give more but I can't figure out what the parameters need to be
    else
      return "#{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}" 
    end
  else
    # something for the rest of the world
    return "#{countryCode['name']}, #{countryCode['countryName']}"
  end
end

def dotInName (fx,yearFile)
  fileshortnew = "#{yearFile}.#{File.basename(fx)[4,2]}.#{File.basename(fx)[6,2]}"  
end

if File.directory?(folderOnGarmin)
  fromWhichFolder = folderOnGarmin
  puts "92. Processing files from #{folderOnGarmin} and also coping those files to #{folderDownload}  +_+_+_+_+_+_+_+_+_+_+_+_\n"
else
  puts "\n94. Processing files from #{folderDownload}\n\nor XXXXXXXXXXXXXXXX FORGOT TO CONNECT GARMIN XXXXXXXXXXXXXXXXXXX\n"
  fromWhichFolder = folderDownload
end # File.directory?(folderOnGarmin)  
puts "\n97. Processing (Massaged) files in #{folderMassaged}\n"
#  fc = file contents
#  fr = file revised
#  ts = time shift (hours)
#  ln = line number

# puts "\nMoving TEMP, i.e. files created on the day of downloaded that may have been incomplete"
puts "104. folderDownload: #{folderDownload}\n"
# /Users/gscar/Dropbox/   Garmin gpx daily logs/2013 Download/2013 Download/
# /Users/gscar/Dropbox/   Garmin gpx daily logs/2013 Download/
Find.find(folderDownload) do |fx|
  # puts "108. File.basename(fx,\".gpx\")[-4,4]: #{File.basename(fx,".gpx")[-4,4]}"
  if File.basename(fx,".gpx")[-4,4]=="TEMP"
    puts "110. fx: #{fx} was moved"
    fm = oldTEMPfiles + File.basename(fx)
    FileUtils.mv fx, fm
  end
end
Find.find(folderMassaged) do |fx|
  # puts "File.basename(fx,\".gpx\")[-4,4]: #{File.basename(fx,".gpx")[-4,4]}"
  if File.basename(fx,".gpx")[-4,4]=="TEMP"
    # puts "fx: #{fx} was moved"
    fm = oldTEMPfiles + File.basename(fx)
    FileUtils.mv fx, fm
  end
end

# Moving files and processing needs to be separate because may have manually moved over files or forgotten to move them over, although if only use this script to process, shouldn't be a problem. But because not that much extra recalculating, will do it separately, although may create some modules for reuse

# Copying files from Garmin to computer
today = Time.now.strftime("%Y%m%d")
if fromWhichFolder == folderOnGarmin
  puts " Copying over original files to computer from Garmin: (#{folderOnGarmin})\n\n"
  Find.find(folderOnGarmin) do |fx|
    # puts "126. Looking at fx: #{fx}"
    if File.file?(fx) # the directory we're looking in is added to the fx list, so have to skip it
      Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
      # Find.prune if File.exist?(fx) != true # get errors trying to process other files on card. Trying to eliminate invisible and wier difles
      yearFile  = File.basename(fx)
      # puts "130. yearFile: #{yearFile}}\n"
      Find.prune if yearFile[1] == '_' # getting weird files like ._20120308.gpx from somewhere. Never could find any of them. This is a crude way to solve it. Probably should be able to eliminate all invisible files, but was having some problem. Might try again.
      yearFile = yearFile[0,4]
      # puts "yearFile: #{yearFile}"
      # Creating filename, fNotToday. Created because used first to check if today, then later to create the file on the hard drive. If today, a different filename is created
      # fNotToday was fnew, but there is an (apparently different) fnew elsewhere and that was confusing
      fNotToday = baseFolderGPX + "#{yearFile} Download/#{File.basename(fx)}"
      # puts "135. fNotToday: #{fNotToday}\n\n"
      # puts "136. today: #{today}  File.basename: #{File.basename(fx, ".*")}. \n\n"
        if !File.exists?(fNotToday) # this goes through all the files on the Garmin  
        if today!=File.basename(fx, ".*")
          FileUtils.cp fx, fNotToday 
          puts "137. \"#{fx}\" copied to \"#{fNotToday}\"\n"
        else # create a temporary file for today so can use it. The next run erase all temp files when script next run
          fTempBasename = File.basename(fx,".gpx") + ".TEMP.gpx"
          ftemp =  "#{baseFolderGPX}/#{yearFile} Download/#{fTempBasename}"
          puts "\"#{fx}\" to be copied to \"#{ftemp}\""
        FileUtils.cp fx, ftemp
        end
      end
    end  
  end # File.file?(fx)
  puts "\nCopying finished.\n\n"
end # if copying files

# Four lines to eject Garmin when done with it
# Won't work until can use with  1.9.2. because nokogirl needs it
# f = FindApp.by_id('com.apple.finder')
# Finder = SDEFParser.makeModule(f)
# finder = Appscript.app("Finder", Finder)
# puts finder.eject("GARMIN")

puts "\n169. Garmin unmounted. Now starting processing of gpx files in #{folderDownload} \n\n"

# Processing files, i.e., adding annotations and locations to the "names". 
Find.find(folderDownload) do |fx|
  if File.file?(fx) # the directory we're looking in is added to the fx list, so have to skip it
    # puts "169. fx: #{fx}"
    if File.exist?(fx)  # checking if file to be processed exists. Probably not needed now as only working with a list of existing files
      Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
      # puts "168. fx: #{fx}. File.basename(fx): #{File.basename(fx)}\n"
      fileTEMP = false
      
      # Establish file name
      yearFile  = File.basename(fx)[0,4]
      # fileshortnew = "#{yearFile}.#{File.basename(fx)[4,2]}.#{File.basename(fx)[6,2]}"
      #  moved to method
      fileshortnew = dotInName(fx,yearFile)
      # puts "175. File.basename(fx): #{File.basename(fx)}. yearFile: #{yearFile}. fileshortnew: #{fileshortnew} \n"
      fnew = "#{baseFolderGPX}#{yearFile} Massaged/#{fileshortnew}.gpx"
      # puts "182. fnew: #{fnew}  ============================\n"
      # puts "191. File.basename(fx, ".TEMP.gpx"): #{File.basename(fx, ".TEMP.gpx")}." # This gives and error, yet the next line works.
      if today==File.basename(fx, ".TEMP.gpx")
        puts "193 fx: #{fx}"
        # Not clear why originally was using timeshifted, seems should just be original filename with TEMP added
        # fileshortnew = timeshifted.strftime("%Y.%m.%d") + ".TEMP" # formatting filename
        fileshortnew = dotInName(fx,yearFile) + ".TEMP" 
        #  year is timeshifted. Not sure whey 
        # fnew = "#{baseFolderGPX}#{year} Massaged/#{fileshortnew}.gpx"
        fnew = "#{baseFolderGPX}#{yearFile} Massaged/#{fileshortnew}.gpx"
        fileTEMP = true
      end #
      
       # first need to see if a processed file for this date exists (except for TEMP) and if so move on
      Find.prune if File.exists?(fnew) && fileTEMP == false 
      # puts "185. fnew: #{fnew} will be processed."
      
      isdst = ""
      dstNote = ""
      act = 0 # no. of ACTIVE LOGs. Needed for summary of script results and adding a counter to each Log segment. The latter is probably only of interest when I'm intentionally creating logs for mountain bike route designing.
      trkpt = 0 # counting to 500 trkpts and then putting in location

      # Read the gpx file into an array line by line. Makes it easier to deal with getting information a few lines ahead (the time)
      # puts "54. fx: #{fx}" # debugging
      arr=IO.readlines(fx) # p.131 Thomas
      alength = arr.length
      alengthOrig = alength
      ln = 2 # could be slightly larger since nothing relevant for several lines
      # alength = alength-5 # since last several lines are irrelevant and I had a problem with probably one too many lines
      # puts "208. ln: #{ln}. < alength: #{alength}"
      while ln<alength
        # puts "210. ln: #{ln}. < alength: #{alength}. fx: #{fx}"        
        if arr[ln] =~ /<name>ACTIVE LOG[0-9]+<\/name>/
          arr[ln+4] =~ /<time>(.*?)Z<\/time>/ # Getting starting datetime for this log
          # a bit weak because it depends on formatting. Better to search for <time>...time> FIX
          
          # AFAI can see the following 15 lines are so are to determine if DST or not, i.e. to define isdst. Doesn't seem necessary. See output of api.timezone, has gmt ond dst offsets. If different 
          datetime = $1 
          # puts "227. datetime #{datetime}" # >> 2013-06-09T19:09:52
          # tp = ParseDate.parsedate datetime # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7 # pre 1.9
          tp = Date._parse(datetime) # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7
          # puts "\n216. datetime: #{datetime} tp: #{tp}. From time of ACTIVE LOG"
          time = Time.gm(tp[:year],tp[:mon],tp[:mday],tp[:hour],tp[:min],tp[:sec]) # Time in Ruby sense (date and time)
          # puts "218. time: #{time}" # Used in labeling ACTIVE LOG
          trkpt = 0 # reset counter since don't need too many desc
          # puts "167"
          # puts "Time.local(tp[0],tp[1],tp[2]): #{Time.local(tp[0],tp[1],tp[2])}" # >>Sun Jun 09 00:00:00 -0700 2013
          if Time.local(tp[:year],tp[:month],tp[:day]).isdst
            isdst = "DST"
          else
            isdst = "ST"
          end # Time.local

          #  Now get the location information 
         alatlon = latlon(arr[ln+2]) 
         # puts "189. fx: #{fx}. ln: #{ln}. datetime: #{datetime}. Time.new(datetime) #{datetime}. "
         puts "246. arr[ln+2]: #{arr[ln+2]}. alatlon: #{alatlon}\n"
         location = loc(alatlon)
         # # Checking out some other stuff. Didn't work. Could look at ExifTool I suppose.
         # wikiSummary = Geonames::WebService.element_to_wikipedia_article lat, lon
         # puts "element_to_wikipedia_article.first.summary: #{element_to_wikipedia_article.first.summary}"
    
      # Timezone
          # timezone = Geonames::WebService.timezone alatlon[0], alatlon[1]
          api = GeoNames.new
          timeZ = api.timezone(lat: alatlon[0], lng: alatlon[1])
          # => timeZ: {"time"=>"2013-11-11 09:19", "countryName"=>"United States", "sunset"=>"2013-11-11 16:52", "rawOffset"=>-8, "dstOffset"=>-7, "countryCode"=>"US", "gmtOffset"=>-8, "lng"=>-118.38361, "sunrise"=>"2013-11-11 06:21", "timezoneId"=>"America/Los_Angeles", "lat"=>33.81222}
          puts "timeZ: #{timeZ}. {timeZ['gmtOffset']}"
          timezone = timeZ['gmtOffset']
          # puts "238: timezone: #{timezone}\n"
         #  puts "239: dstOffset: #{timeZ['dstOffset']}\n"
         #           dst_offset =  timeZ['dstOffset']                           # Is this for the day it's done? Was timezone.dst_offset
          gmt_offset =  timeZ['gmtOffset']                           # not affected by DST. Was timezone.gmt_offset
          timezone_id = timeZ['timezoneId']                          # Wordy version of timezone. Was timezone.timezone_id
          # puts "\n isdst: #{isdst}\n dst_offset: #{dst_offset}\n gmt_offset: #{gmt_offset}\n timezone_id: #{timezone_id}\n"
          # puts "244. timezone: #{timezone}. gmt_offset: #{gmt_offset}. timezone_id: #{timezone_id}\n"
          # Create what will be new <desc> line in the gpx.
          # desc = "<desc>#{location}. GMT #{gmt_offset}, DST #{dst_offset}. Is #{isdst}</desc>\n"
          if isdst == "DST"
            dstNote = ", DST #{dst_offset}"
          end
          if isdst == "ST" # case might be better
            offset = gmt_offset
          else
            offset = dst_offset            
          end # if isdst
          # Generally offset is a whole number, so easier to see it as an integer, but for the cases that are need to leave as float
          # puts "offset: #{offset}. offset.round.to_f: #{offset.round.to_f}"
          puts "offset: #{offset}"
          if offset.round.to_f == offset
            offset = offset.to_i
            gmt_offset = gmt_offset.to_i
            # puts "offset: #{offset}. offset.to_i:#{offset.to_i}"
          end # if offset
          desc = "<desc>#{timezone_id}. GMT #{gmt_offset}#{dstNote}. Is #{isdst}</desc>\n" # why should the \n be needed? But it is
          # Read and write the time zone as found from coordinates into the name or a line below <desc>  
          act += 1 # want the counter to index here so starts with 1 and count is correct for summary
          timeshifted = time +  (offset*3600)
          # puts "275. timeshifted: #{timeshifted}"
          timeshifted4name = timeshifted.strftime("%Y-%m-%d %H:%M:%S GMT#{offset}")
          # puts "274. #{File.basename(fx)}. timeshifted: #{timeshifted}. timeshifted4name: #{timeshifted4name}"
          # change the name line. Older versions and temporary versions
          # arr[ln] = "<name>ACTIVE LOG :: #{timeshifted4name}. #{timezone_id}</name>\n"  # older version
          # arr[ln] = "<name>TX#{act}</name>\n"  # keeping it simple for tracks with many logs
          arr[ln] = "<name>#{location} ::  #{timeshifted4name}. (#{act})</name>\n"
          arr.insert(ln+1, desc) # Just to be safe, this is written after the new "name"
          alength +=1 # added a line to the array
        end  # matching ACTIVE
        # loop below puts location information every 100 lines, but I haven't ever used that information, so will comment it out
=begin
        if arr[ln] =~ /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/
          if trkpt>99
              alatlon = latlon(arr[ln]) 
              location = loc(alatlon)
              descTP = "    <desc>#{location}</desc>\n"
              arr.insert(ln+3, descTP)
              trkpt = 0
            else
              trkpt +=1
          end # trkpt>99
        end # arr[ln] =~  /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/
=end
        ln +=1
      end # while
      # create the file (is this really creating the file or just the text for the file)
      fr = arr.join
      # write back file
      # puts "\n381. #{File.basename(fx)}. timeshifted: #{timeshifted}. timeshifted4name: #{timeshifted4name}"
      # fileshortnew = timeshifted.strftime("%Y.%m.%d") # formatting filename. had to do this earlier
      # puts "306. timeshifted: #{timeshifted}"
      year = timeshifted.strftime("%Y")
    if File.exist?(fnew)
        puts "\n\n############# ALL DONE #################\n\nGarmin can be unmounted."
        # Launchy.open("http://www.strava.com")
        exit
    else
       fh = File.new(fnew, "w")
       fh.puts fr
       fh.close
       puts "\n316. Original file #{fx} processed. \nFile had #{alengthOrig} lines with #{act} ACTIVE LOGs.\nNew file written to, and \nnow has #{alength} lines"
    end #  File.exist?(fnew)
    else 
      puts "Warning: #{fx} doesn't exist, so nothing to process" 
    end # File.exists. 
    puts ""  # want a blank line
  end # File is a file and not a directory
end # Find.find(src) do |fn| 