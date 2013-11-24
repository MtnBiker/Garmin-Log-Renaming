#!/usr/bin/env ruby
require 'rubygems'
require "date"
require 'parsedate'
require 'geonames'
require 'find'
# require 'launchy'
require 'fileutils'
require 'geocoder' # try when figure out how to add gems to iMac

# AND find the time zone using coordinates. Done, ONLY SEEMS TO WORK IF DST IS THE SAME AS NOW. Also something weird about Santiago done in June
# Could check if date processing is close to date of file because of da
#  Also need to deal with whatever creates errors with the web services. Make more robust or give better error messages. And maybe try again.
=begin
  TODO fix time zone error. Shows -7 during standard time in Calif.  Not seeing this now 2013.01.07. Maybe wait for daylight time to see if there is a problem
=end
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
folderDownload = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/2013 Download/"
folderMassaged = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/2013 Massaged/"
folderOnGarmin = "/Volumes/GARMIN/" # NEED TO COMBINE with copy files over
oldTEMPfiles = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/old TEMP files/" # for files created on day of download which may not be complete
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
  location = "If you're seeing this sentence, Geocoder isn't set up. Needs to be put in two places"
  places_nearby = Geonames::WebService.find_nearby_place_name arr[0], arr[1]
  # puts "Coordinates input #{arr[0]}, #{arr[1]}"
  # location = Geocoder.search("#{arr[0]}, #{arr[1]}")
  # puts "location from Geocoder: #{location}" # if geocoder loaded. If gets good info, maybe change
  return "#{places_nearby.first.name}, #{places_nearby.first.country_name}"
end

if File.directory?(folderOnGarmin)
  fromWhichFolder = folderOnGarmin
  puts "Processing files from #{folderOnGarmin} and also coping those files to #{folderDownload}\n"
else
  puts "Processing files from #{folderDownload}\n\nor XXXXXXXXXXXXXXXX FORGOT TO CONNECT GARMIN XXXXXXXXXXXXXXXXXXX"
  fromWhichFolder = folderDownload
end
puts "\nProcessed (Massaged) files in #{folderMassaged}\n"
#  fc = file contents
#  fr = file revised
#  ts = time shift (hours)
#  ln = line number

puts "\nMoving TEMP, i.e. files created on the day of downloaded that may have been incomplete"
# puts "last file in downloads folder: #{Find.find(folderDownload).last}. Trying to figure out how to find that"
Find.find(folderDownload) do |fx|
  # puts "File.basename(fx,\".gpx\")[-4,4]: #{File.basename(fx,".gpx")[-4,4]}"
  if File.basename(fx,".gpx")[-4,4]=="TEMP"
    # puts "fx: #{fx} was moved"
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
    puts "fx: #{fx}"
    if File.file?(fx) # the directory we're looking in is added to the fx list, so have to skip it
      Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
      yearFile  = File.basename(fx)
      yearFile = yearFile[0,4]
      # puts "yearFile: #{yearFile}"
      fnew = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/#{yearFile} Download/#{File.basename(fx)}"
      if !File.exists?(fnew) # this goes through all the files on the Garmin which may be a bit slow as the card fills up. If too slow fix to stop after reaching first duplicate
        # puts "today: #{today}  File.basename: #{File.basename(fx, ".*")}"
        if today!=File.basename(fx, ".*") # don't want to copy today in case I'm downloading before the day is done which I might do to see exercise for the day. See else below as this is changed
          puts "\"#{fx}\" copied to \"#{fnew}\""
          FileUtils.cp fx, fnew
        else # create a temporary file for today so can use it. The next run erase all temp files when script next run
          fTempBasename = File.basename(fx,".gpx") + ".TEMP.gpx"
          ftemp =  "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/#{yearFile} Download/#{fTempBasename}"
          FileUtils.cp fx, ftemp
          puts "\"#{fx}\" copied to \"#{ftemp}\""
        end
      end
    end  
  end # File.file?(fx)
  puts "\nCopying finished.\n\n"
end # if copying files

puts "\nNow starting processing of gpx files in #{fromWhichFolder}.\n\n"

# Processing files, i.e., adding annotations and locations to the "names". 
Find.find(folderDownload) do |fx|
  if File.file?(fx) # the directory we're looking in is added to the fx list, so have to skip it
    # puts "46. fx: #{fx}"
    if File.exist?(fx)  # checking if file to be processed exists. Probably not needed now as only working with a list of existing files
      Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
      # puts "Line 49. fx: #{fx}"
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
      while ln<alength
        if arr[ln] =~ /<name>ACTIVE LOG[0-9]+<\/name>/

          arr[ln+4] =~ /<time>(.*?)Z<\/time>/ # Getting starting datetime for this log
          # a bit weak because it depends on formatting. Better to search for <time>...time> FIX
          datetime = $1 
          tp = ParseDate.parsedate datetime # year 0, month 1, day 2, hour 3, min. 4, sec. 5, tz 6, weekday 7
          time = Time.gm(tp[0],tp[1],tp[2],tp[3],tp[4],tp[5]) # Time in Ruby sense (date and time)
          trkpt = 0 # reset counter since don't need too many desc

          if Time.local(tp[0],tp[1],tp[2]).isdst
            isdst = "DST"
          else
            isdst = "ST"
          end # Time.local

          #  Now get the location information 
         alatlon = latlon(arr[ln+2]) 
         location = loc(alatlon)
         # # Checking out some other stuff. Didn't work. Could look at ExifTool I suppose.
         # wikiSummary = Geonames::WebService.element_to_wikipedia_article lat, lon
         # puts "element_to_wikipedia_article.first.summary: #{element_to_wikipedia_article.first.summary}"
    
      # Timezone
          timezone = Geonames::WebService.timezone alatlon[0], alatlon[1]
          dst_offset = timezone.dst_offset                            # Is this for the day it's done? 
          gmt_offset = timezone.gmt_offset                            # not affected by DST
          timezone_id = timezone.timezone_id                          # Wordy version of timezone
          # puts "\n isdst: #{isdst}\n dst_offset: #{dst_offset}\n gmt_offset: #{gmt_offset}\n timezone_id: #{timezone_id}\n"
          # Create what will be new <desc> line in the gpx.
          # desc = "<desc>#{location}. GMT #{gmt_offset}, DST #{dst_offset}. Is #{isdst}</desc>\n"
          if isdst == "DST"
            dstNote = ", DST #{dst_offset}"
          end
        if isdst == "ST" # case might be better
            offset = gmt_offset
          else
            offset = dst_offset            
          end
          # Generally offset is a whole number, so easier to see it as an integer, but for the cases that are need to leave as float
          # puts "offset: #{offset}. offset.round.to_f: #{offset.round.to_f}"
          if offset.round.to_f == offset
            offset = offset.to_i
            gmt_offset = gmt_offset.to_i
            # puts "offset: #{offset}. offset.to_i:#{offset.to_i}"
          end
          desc = "<desc>#{timezone_id}. GMT #{gmt_offset}#{dstNote}. Is #{isdst}</desc>\n" # why should the \n be needed? But it is
          # Read and write the time zone as found from coordinates into the name or a line below <desc>  
          act += 1 # want the counter to index here so starts with 1 and count is correct for summary
          timeshifted = time +  (offset*3600)
          timeshifted4name = timeshifted.strftime("%Y-%m-%d %H:%M:%S GMT#{offset}")
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
      # create the file
      fr = arr.join
      # write back file
      puts "\n#{File.basename(fx)}. timeshifted: #{timeshifted}. timeshifted4name: #{timeshifted4name}"
      fileshortnew = timeshifted.strftime("%Y.%m.%d") # formatting filename
      year =         timeshifted.strftime("%Y")
      fnew = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/#{year} Massaged/#{fileshortnew}.gpx"
      if today==File.basename(fx, ".TEMP.gpx")
        fileshortnew = timeshifted.strftime("%Y.%m.%d") + ".TEMP" # formatting filename
        fnew = "/Users/gscar/Documents/GPS-Maps-docs/   Garmin gpx daily logs/#{year} Massaged/#{fileshortnew}.gpx"
      end
      if File.exist?(fnew)
        # puts "WARNING: #{fnew} already exists, so nothing was done.\n END WARNING" # if need to process an entire folder uncomment this and comment the following two lines
        puts "\nReached an existing file working backwards through the folder, so stopped processing\n\n############# ALL DONE #################\n\nGarmin can be unmounted."
        # Launchy.open("http://www.strava.com")
          exit
          else
          fh = File.new(fnew, "w")
          fh.puts fr
          fh.close
          puts "Original file #{fx} processed. \nFile had #{alengthOrig} lines with #{act} ACTIVE LOGs.\nNew file written to, and \nnow has #{alength} lines"
      end #  File.exist?(fnew)
    else 
      puts "Warning: #{fx} doesn't exist, so nothing to process" 
    end # File.exists. 
    puts ""  # want a blank line
  end # File is a file and not a directory
end # Find.find(src) do |fn| 