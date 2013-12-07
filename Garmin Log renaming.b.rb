#!/usr/bin/env ruby
require 'rubygems'
require "date"
require 'find'
require 'fileutils'
# require 'Appscript' # apparently not needed. 
require "tzinfo"
require './lib/geonames.rb' # needs gem addressable and json

=begin
Works with Ruby 1.9 and with 2.0 
Until this is removed this version isn't complete, use .d
  TODO fix time zone error. Shows -7 during standard time in Calif.  Not seeing this now 2013.01.07. Maybe wait for daylight time to see if there is a problem
=end
# .b added MotionX, although a bit was done before moving
# .c an attempt at a rewrite using Classes. Major cleanup by adding methods and general clean up, alhtough didn't use classes. Need to look at more.
# .d now using geoname.rb which needs 1.9 which also meant some updating since parsedate was gone. Previous used geonames gem from https://github.com/manveru/geonames

baseFolderGPX   = "/Users/gscar/Dropbox/   GPX daily logs/" # for gpx files
folderOnGarmin  = "/Volumes/GARMIN/" # NEED TO COMBINE with copy files over
garminDownload  = baseFolderGPX + "2013 Download/"
motionXdownload = baseFolderGPX + "2013  MotionX Download/"
folderMassaged  = baseFolderGPX + "2013 Massaged/"
oldTEMPfiles    = baseFolderGPX + "old TEMP files/" # for files created on day of download which may not be complete

# Read the .ruby-version and report it. Run window shows version running.

def getRubyVersion(fn)
  if fn.length > 1
     puts  ".ruby-version: #{File.open(fn).gets.chop}. Version actually running is in purple area above. Can't tell if ruby is selected by #{fn} or TM Preferences. At this time rbenv isn't functioning for TM. 2013.11.23"
   else
     puts "fn: #{fn} isn't in this folder. Need to change the script to go until finds one."
  end
end

def garminOrFolder(folderOnGarmin,folderDownload)
  if File.directory?(folderOnGarmin)
    fromWhichFolder = folderOnGarmin
    # puts "\n38. Copying gpx from  Garmin ( #{folderOnGarmin})  to my Mac (#{folderDownload}). \n"
  else
    puts "\n40. Garmin not mounted so skip to next step or XXXXXXXXXXXXXXXX FORGOT TO CONNECT GARMIN XXXXXXXXXXXXXXXXXXX\n"
    fromWhichFolder = folderDownload
  end # File.directory?(folderOnGarmin)  
  return fromWhichFolder
end

def removeDayOf(folderDownload,folderMassaged, oldTEMPfiles)
  # first the virgin files
  Find.find(folderDownload) do |fx|
    # puts "49. File.basename(fx,\".gpx\")[-4,4]: #{File.basename(fx,".gpx")[-4,4]}"
    if File.basename(fx,".gpx")[-4,4]=="TEMP"
      # puts "51. fx: #{fx} was moved"
      fm = oldTEMPfiles + File.basename(fx)
      FileUtils.mv fx, fm
    end
  end 
 #  Now the massaged files
  Find.find(folderMassaged) do |fx|
    # puts "58.File.basename(fx,\".gpx\")[-4,4]: #{File.basename(fx,".gpx")[-4,4]}"
    if File.basename(fx,".gpx")[-4,4]=="TEMP"
      # puts "60. fx: #{fx} was moved"
      fm = oldTEMPfiles + File.basename(fx)
      FileUtils.mv fx, fm
    end
  end
   
end

def copyFiles(folderOnGarmin, baseFolderGPX) # from Garmin to Year Downloads file
  i = 0
  today = Time.now.strftime("%Y%m%d")
  puts "\n1. (72). Begin copying gpx from  Garmin ( #{folderOnGarmin})  to my Mac (#{baseFolderGPX})."
  Find.find(folderOnGarmin) do |fx|
    # puts "126. Looking at fx: #{fx}"
    if File.file?(fx) # the directory we're looking in is added to the fx list, so have to skip it
      Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
      yearFile  = File.basename(fx)
      # puts "130. yearFile: #{yearFile}}\n"
      Find.prune if yearFile[1] == '_' # getting weird files like ._20120308.gpx from somewhere. Never could find any of them. This is a crude way to solve it. Probably should be able to eliminate all invisible files, but was having some problem. Might try again.
      yearFile = yearFile[0,4]
      # puts "yearFile: #{yearFile}"
      # Creating filename, fNotToday. Created because used first to check if today, then later to create the file on the hard drive. If today, a different filename is created
      fNotToday = baseFolderGPX + "#{yearFile} Download/#{File.basename(fx)}"
      # puts "83. fNotToday: #{fNotToday}\n\n"
      # puts "84. today: #{today}  File.basename: #{File.basename(fx, ".*")}. \n\n"
      if !File.exists?(fNotToday) # this goes through all the files on the Garmin  
        if today!=File.basename(fx, ".*")
          i += 1
          FileUtils.cp fx, fNotToday 
          # puts "89. \"#{fx}\" copied to "#{fNotToday}\"\n"
        else # create a temporary file for today so can use it. The next run erase all temp files when script next run
          i += 1
          fTempBasename = File.basename(fx,".gpx") + ".TEMP.gpx"
          ftemp =  "#{baseFolderGPX}/#{yearFile} Download/#{fTempBasename}"
          # puts "94. \"#{fx}\" to be copied to \"#{ftemp}\""
        FileUtils.cp fx, ftemp
        end # if today
      end
    end  
  end # File.file?(fx)
  puts "\n2. (101) Copying finished. #{i} gpx files copied from Garmin to #{baseFolderGPX}…\n\n"  
end # from Garmin to Year Downloads file

# def ejectGarmin(folderDownload)
#   # Four lines to eject Garmin when done with it
#   # Won't work until can use with  1.9.2. because nokogirl needs it
#   f = FindApp.by_id('com.apple.finder')
#   Finder = SDEFParser.makeModule(f)
#   finder = Appscript.app("Finder", Finder)
#   puts finder.eject("GARMIN")  
# puts "\n109. Garmin unmounted. Now starting processing of gpx files in #{folderDownload} \n\n"
# end

def dotInName (fx,yearFile)
  fileshortnew = "#{yearFile}.#{File.basename(fx)[4,2]}.#{File.basename(fx)[6,2]}"  
end

def copyRename(baseFolderGPX, folderDownload) # from Year Downloads to Year Massaged folder and create list of those new files
  puts "3. (118). Copying gpx file from #{folderDownload} to Massaged Folder and renaming files with a YYYY.MM.dd format."
  newFiles = [] 
  i = 0
  folderNew = ""
  today = Time.now.strftime("%Y%m%d")
  Find.find(folderDownload) do |fx|
    # puts "121. fx: #{fx}. File.file?(fx): #{File.file?(fx)}. "
   next if !File.file?(fx) # the directory we're looking in is added to the fx list, so skip it. # Was  Find.prune if … which didn't work
    # puts "123. fx: #{fx}"
    # Find.prune if  File.exist?(fx)  # checking if file to be processed exists. Probably not needed now as only working with a list of existing files
    Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
    # puts "127. fx: #{fx}. File.basename(fx): \n" #{File.basename(fx)}
    # Establish file name
    yearFile  = File.basename(fx)[0,4]
    # fileshortnew = "#{yearFile}.#{File.basename(fx)[4,2]}.#{File.basename(fx)[6,2]}"
    #  moved to method
    fileshortnew = dotInName(fx,yearFile)
    # puts "134. File.basename(fx, \".TEMP.gpx\"): #{File.basename(fx, ".TEMP.gpx")}."
    # puts "135. File.basename(fx): #{File.basename(fx)}. yearFile: #{yearFile}. fileshortnew: #{fileshortnew} \n"
    folderNew = "#{baseFolderGPX}#{yearFile} Massaged"
    # puts "182. fnew: #{fnew}  ============================\n"
    # puts "137. today: #{today}==File.basename(fx, \".TEMP.gpx\"): #{File.basename(fx, ".TEMP.gpx")}"
    if today==File.basename(fx, ".TEMP.gpx")
      # puts "140 fx: #{fx}. "
      # Not clear why originally was using timeshifted, seems should just be original filename with TEMP added
      # fileshortnew = timeshifted.strftime("%Y.%m.%d") + ".TEMP" # formatting filename
      fileshortnew = dotInName(fx,yearFile) + ".TEMP" 
      #  year is timeshifted. Not sure whey 
      # fnew = "#{baseFolderGPX}#{year} Massaged/#{fileshortnew}.gpx"
      fnew = "#{folderNew}/#{fileshortnew}.gpx"
      # fileTEMP = true
    else # all but today's file
      fnew = "#{folderNew}/#{fileshortnew}.gpx"
      # puts "150. fnew: #{fnew}."
      # fileTEMP = false
    end # today==. Add TEMP to today's files
    if !File.exists?(fnew)
      newFiles << fnew
      FileUtils.cp(fx, fnew) 
      i =+ 1
    end  # !File.exists?(fnew). add to newFiles 
  end # Find.find(folderDownload) do |fx|. The basic grind
  puts "\n 5. (159). Copying and renaming finished. #{i} gpx files copied to #{folderNew}.\n\n" 
  # puts "\n160. newFiles: #{newFiles}.\n    Not exactly the same as newFiles below."
  return newFiles   
end # Copy and rename files from Year Downloads to Year Massaged folder and create list of those new files

def copyMotionX(newFiles,baseFolderGPX, folderDownload)
  puts "\n6. (167) Copying MotionX gpx files\n from #{folderDownload} to Massaged Folder and \nadding to newFiles, the list of files to be processed."
  i = 0
  folderNew = ""
  today = Time.now.strftime("%Y%m%d")
  Find.find(folderDownload) do |fx|
    # puts "121. fx: #{fx}. File.file?(fx): #{File.file?(fx)}. "
   next if !File.file?(fx) # the directory we're looking in is added to the fx list, so skip it. # Was  Find.prune if … which didn't work
  # puts "\n174. fx: #{fx}"
  # Find.prune if  File.exist?(fx)  # checking if file to be processed exists. Probably not needed now as only working with a list of existing files
  Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
  # puts "\n127. fx: #{fx}. File.basename(fx): \n" #{File.basename(fx)}
  # Establish file name
  yearFile = File.basename(fx)[0,4]
  dateFile = File.basename(fx)[0,8]
  folderNew = "#{baseFolderGPX}#{yearFile} Massaged" # MIGHT MOVE THIS FROM THE TWO DEFS
  
  newBasename = "#{dotInName(fx,yearFile)}.#{File.basename(fx)[9..-5]}" # gets all but date and .gpx. Would work in Garmin version too I think
  # puts "\n\n189. newBasename: #{newBasename}"
  
  # THIS IS ALL WRONG FOR THE FILE NAME I'M USING. CAN'T CHANGE FILE NAME BECAUSE MAY HAVE MULTIPLE DOWNLOADS FOR THE DAY
   # if today==File.basename(fx, ".TEMP.gpx")
#      # puts "140 fx: #{fx}. "
#      # Not clear why originally was using timeshifted, seems should just be original filename with TEMP added. GARMIN DATES FILENAMES ACCORDING LOCAL TIME, SO THAT HAS SOMETHING TO DO WITH IT.
#      # fileshortnew = timeshifted.strftime("%Y.%m.%d") + ".TEMP" # formatting filename
  # puts "\n194. today: #{today}. dateFile: #{dateFile}"
  if today==dateFile
      # puts "193 fx: #{fx}"
      fileshortnew = newBasename + ".TEMP" 
      fnew = "#{folderNew}/#{fileshortnew}.gpx"
      # puts "201. fnew: #{fnew}."
   else # all but today's file
      fnew = "#{folderNew}/#{newBasename}.gpx"
      # puts "204. fnew: #{fnew}."
    end # today==. Add TEMP to today's files
    if !File.exists?(fnew)
      newFiles << fnew
      FileUtils.cp(fx, fnew) 
      i =+ 1
    end  # !File.exists?(fnew). add to newFiles 
 
 
  end # Find.find(folderDownload) do |fx|. The basic grind
  puts "\n215. Copying and renaming finished. #{i} gpx files copied to #{folderNew}.\n\n" 
  # puts "\n160. newFiles: #{newFiles}.\n    Not exactly the same as newFiles below."
  return newFiles   
end

def whichGPSr(firstLine) # So far the first line of the gpx file varies for each of my methods of tracking: Garmin, MotionX, Strava, so can determine which one it is. Needed because formatting is a bit different
  # puts "\n215. firstLine: #{firstLine}. firstLine.length: #{firstLine.length}."
  case firstLine.length # using ranges in case I count wrong and puts a cushion in if one or two characters change
  when (54..57)
    whichGPSr = "Garmin"
  when (37..40)  
    whichGPSr = "Strava"
  else
    whichGPSr = "MotionX" # will have to make this more robust when get another format
  end
  return whichGPSr
end

def timeUTC(myDatetime)
  # All this is doing is taking the T out and adding UTC to the end. 
  # 2013-11-27T22:57:13 ==> 2013-11-27 22:57:13 UTC
  tp = Date._parse(myDatetime) # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7
  timeUTC = Time.gm(tp[:year],tp[:mon],tp[:mday],tp[:hour],tp[:min],tp[:sec]) # Time in Ruby sense (date and time) for this track, of course UTC  
end

def latlon(line)
  #  Extracting lat and lon from trkpt line 
  # <trkpt lat="38.329948" lon="-119.636582"> # this shows format of the line with lat and lon
  line =~ /<trkpt lat=\"(\-?[\d\.]+)\" lon=\"(\-?[\d\.]+)\">/ # (\-?[\d\.]+) gets the sign and the digits
   # lat = $1,  lon = $2
  return alatlon=[$1,$2]
end

def desc(timezoneId, gmtOffset, dstOffset, dst, timeUTC)
  # desc is Time Zone Name, UTC±x, DST = ±x, Is ST/DST, timeUTC
  #  <desc>America/Mazatlan. GMT -7, DST -6.0. Is DST</desc>
  # Daylight Savings or not, and format end
  if dst
    midText = "DST #{dstOffset}. Is DST"
  else
    midText = "Is ST"
  end
  return "  <desc>#{timezoneId}. GMT #{gmtOffset}. #{midText}. #{timeUTC}</desc>\n"
end

def prettyTime(tz, timeUTC)
  timeLocal = tz.utc_to_local(DateTime.new(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)) # should be tzn, but testing with -7. Doesn't work either way
  # puts "\n206. timeLocal: #{timeLocal}. This is the correct LOCAL time, but shows UTC, but it's really some other time zone."

  timePretty = timeLocal.strftime("%A, %B %d, %Y %I:%M%p")
  # puts "\n101. timePretty: #{timePretty}. Using timeLocal, i.e. utc_to_local. Will have to add time zone identifier manually"
  tzi = tz.period_for_utc(Time.utc(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).zone_identifier
  timePretty = "#{timePretty} #{tzi}"  
end

def loc(arr)
  # # Checking out some other stuff. Didn't work. Could look at ExifTool I suppose.
  # wikiSummary = Geonames::WebService.element_to_wikipedia_article lat, lon
  # puts "element_to_wikipedia_article.first.summary: #{element_to_wikipedia_article.first.summary}"

  api = GeoNames.new
  latIn = arr[0]
  longIN = arr[1]
  countryCode = api.country_code(lat: latIn, lng: longIN)
  # puts "\n72. countryCode: #{countryCode} \n countryCode['countryCode']: #{countryCode['countryCode']}"
  if countryCode['countryCode'] === "US"
    # neighborhood only works in the US and is supplied by Zillow
    neigh = api.neighbourhood(lat: latIn, lng: longIN)
    # puts "\n277. For #{latIn}, #{longIN}: neigh: #{neigh}" # "/n #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}\n" 
    #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}"
    if neigh == nil
      puts "280. Data not available for this location from Zillow. lat, long: #{latIn}, #{longIN}\n   ########### Should find a better source than country_code}" # Should write a work
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

# Get date, different for Garmin and MotionX
def getDatetime(whichGPSr, arrLines, ln)
  # puts "\n295. whichGPSr: #{whichGPSr}"
  case whichGPSr
    # Getting starting datetime for this log
       # a bit weak because it depends on formatting. Better to search for <time>...time> FIX      
  when "Garmin"
    arrLines[ln+4] =~ /<time>(.*?)Z<\/time>/
    myDatetime = $1
  when "MotionX"
    arrLines[ln+5] =~ /<time>(.*?)Z<\/time>/      
    myDatetime = $1
    # myDatetime = myDatetime[0..-5] # MotionX has more detail than Garmin and I thought it was causing a problem later, but apparently not. Can delete this when MotionX is working 
  end
  # puts "307. myDatetime: #{myDatetime}"
  return myDatetime  
end



# ================= End of defs and beginning of actions ##############################

getRubyVersion("./\.ruby-version") # for testing can turn this on and off. Couldn't make it work when file name was not passed in. 
puts "\n317. Starting multi-step process of copying gpx files from Garmin to \n     #{garminDownload} for archiving, \n     copying a renamed set to #{folderMassaged} for annotating the tracks with location and local time.\n     The status of each step will be listed."

# Determine if Garmin is mounted, and if not just process from garminDownload
fromWhichFolder = garminOrFolder(folderOnGarmin,garminDownload)

# Remove TEMP files from garminDownload and folderMassaged. These are files created on the day of previous download and may be incomplete
removeDayOf(garminDownload,folderMassaged, oldTEMPfiles)

# Copy gpx files from Garmin to Year Download folder, if that option is selected
copyFiles(folderOnGarmin, baseFolderGPX) if fromWhichFolder == folderOnGarmin

# ejectGarmin(garminDownload) # not working. Run to see errors. Not critical, so will move on for now FIX

# puts "\n\n316. Move and rename  Garmin files from garminDownload to folderMassaged"
# Move and rename  Garmin files from garminDownload to folderMassaged
newFiles = copyRename(baseFolderGPX, garminDownload)  
# puts "332. newFiles Garmin: \n#{newFiles.join}." # => WANT TO LIST LINE BY LINE, LATER, SHOULD BE EASY WITH AN ARRAY

# puts "\n\n321. Copy (and rename?) MotionX files to folderMassaged. WILL HAVE TO BRING IN newFiles and ADD to it."
# Copy (and rename?) MotionX files to folderMassaged. WILL HAVE TO BRING IN newFiles and ADD to it.
newFiles = copyMotionX(newFiles,baseFolderGPX, motionXdownload)

countNewFiles = newFiles.length
puts "\n1. (339). #{countNewFiles} MotionX and Garmin to be annotated: \n#{newFiles.join("\n")}"

# Annotate the new files in folderMassaged. 
i = 0
while i<countNewFiles # not sure if this is a good way to cycle through the files
  fx = newFiles[i]
  # puts "\n345. i: #{i}. fx: #{fx}"
  arrLines=IO.readlines(fx) # p.131 Thomas
  alength = arrLines.length
  alengthOrig = alength
  whichGPSr = whichGPSr(arrLines[0])
  # puts "\n347. whichGPSr: #{whichGPSr}"
  ln = 2 # don't need the first lines for looking for <name>
  while ln<alength
    # puts "354. i: #{i}. ln < alength: #{ln} < #{alength}. fx: #{fx}"        
    # if arrLines[ln] =~ /<name>ACTIVE LOG[0-9]+<\/name>/ # Garmin exclusively
    if arrLines[ln] =~ /<name>(.*?)<\/name>/ 
      myDatetime = getDatetime(whichGPSr, arrLines, ln)
      # puts "357. myDatetime: #{myDatetime}."
      case whichGPSr # crude
      when "Garmin"
        # puts "358. ln: #{ln}. arrLines[ln+2]: #{arrLines[ln+2]}"
         alatlon = latlon(arrLines[ln+2]) # getting coordinates in a usable form
      when "MotionX"
        # puts "361. ln: #{ln}. arrLines[ln+3]: #{arrLines[ln+3]}"
         alatlon = latlon(arrLines[ln+3])
      end
      # puts  "\n223. myDatetime: #{myDatetime}.
      # alatlon = latlon(arrLines[ln+2]) # getting coordinates in a usable form
      
      # puts "369. alatlon: #{alatlon}. myDatetime: #{myDatetime}"
      timeUTC = timeUTC(myDatetime)
      # puts "\n225. timeUTC: #{timeUTC}."
      # Now work on getting time variables and location for new <name> and added or new <desc>
      # Was: desc = "<desc>#{timezone_id}. GMT #{gmt_offset}#{dstNote}. Is #{isdst}</desc>\n" # why should the \n be needed? But it is
      api = GeoNames.new
      # puts "timeZ IS ONLY GETTING THE TIMEZONE FOR COORDINATES, BUT OTHER INFORMATION NOT FOR **MY DATE** OF INTEREST BUT FOR **CURRENT** TIME
      # IN OTHER WORDS I still have to determine daylight savings time some other way"
      timeZ = api.timezone(lat: alatlon[0], lng: alatlon[1])
      # puts "\n379. timeZ: #{timeZ}."
      timezoneId = timeZ["timezoneId"]
      gmtOffset = timeZ["gmtOffset"]
      dstOffset  = timeZ["dstOffset"]
      # tz = TZInfo::Timezone.get('America/New_York')
      tz = TZInfo::Timezone.get(timeZ["timezoneId"]) #  using timeZ which is the time zone for particular coordinates
      dst = tz.period_for_utc(Time.utc(timeUTC.year, timeUTC.month, timeUTC.day, timeUTC.hour, timeUTC.min, timeUTC.sec)).dst? # dst Daylight Savings Time
      # puts "dst: #{dst}" #  returns true or false and seems to work
      desc = desc(timezoneId, gmtOffset, dstOffset, dst, myDatetime)
      # puts "\n 266. #{desc}."
      
      #  <name> Location. Pretty Time
      location = loc(alatlon)       
      prettyTime = prettyTime(tz, timeUTC)
      # puts "\n279 prettyTime: #{prettyTime} with manually added time zone identifier"
      name = "  <name>#{location}. #{prettyTime}</name>\n"
      # puts name
      # Add to the array which is the file. MotionX already has a <desc> which will be replaced
      arrLines[ln] = name
      if whichGPSr=="Motion X"
        arrLines[ln=1] = desc
      else
        arrLines.insert(ln+1, desc) # Just to be safe, this is written after the new "name"
      end # Writes to different line depending on whichGPSr
      alength +=1 # added a line to the array because added the desc line
      # puts "403. alength: #{alength}"
     end # Find each <trk> by looking for <name> and annotating
    ln +=1
  end # while going through an array of the content of the file and annotating the array
  
  # Now write the new file,i.e, replace with revised which is in an array, arrLines 
  fr = arrLines.join
  fh = File.new(fx, "w")
  fh.puts fr
  fh.close
  
  puts "\n414. File #{i+1}. #{fx} processed. \nFile had #{alengthOrig} lines and now has #{alength} lines\n"
  
  i +=1 # file counter
end # while or whatever it turns out to be, this is going through each new file

puts "419. All done. #{countNewFiles} files annotated in #{folderMassaged}"

# Process files, i.e., adding annotations and locations to the "names". 
# NOW HAVE TO SEPARATE OUT WHICH FILES ARE NEW AND WHICH ARE OLD.                                          KEEP TRACK OF THE FILES THAT HAVE MOVED, JUST CREATE AN ARRAY AND GO THRU THEM !!!!!'






#  Trying to find a way to get the line number of the script. Would be handy for debugging
# echo "Left:  »${TM_CURRENT_LINE:0:TM_LINE_INDEX}«"
# puts $TM_LINE_INDEX # doesn't do anything
# echo "Right: »${TM_CURRENT_LINE:TM_LINE_INDEX}«"
# puts "\nTM_LINE_INDEX: #{$TM_LINE_INDEX}. ${TM_CURRENT_LINE:0:TM_LINE_INDEX}" # first part is blank, 
# ++++++++++================ Test stuff
# puts "ENV[\"PATH\"]: #{ENV['PATH']}"


