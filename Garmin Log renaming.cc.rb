#!/usr/bin/env ruby
require 'rubygems'
require "date"
# require 'geonames'
require 'find'
require 'fileutils'
# require 'geocoder' # try when figure out how to add gems to iMac
require 'Appscript'
# require './lib/geonames.rb'

=begin
Until this is removed this version isn't complete, use .d
  TODO fix time zone error. Shows -7 during standard time in Calif.  Not seeing this now 2013.01.07. Maybe wait for daylight time to see if there is a problem
TODO Must manually change new year
=end
# .c an attempt at a rewrite using Classes. Deleted everything but file locations. Will cover over from previous version, but will rather than patching copying will make me think about how good the good is. Up through copying the files over, I can't see any need for something like classes. But I did move each action into a method which is much neater than before.
# .d now using geoname.rb which needs 1.9 which also meant some updating since parsedate was gone. Previous used geonames gem from https://github.com/manveru/geonames

baseFolderGPX  = "/Users/gscar/Dropbox/   Garmin gpx daily logs/" # for gpx files
folderDownload = baseFolderGPX + "2013 Download/"
folderMassaged = baseFolderGPX + "2013 Massaged/"
folderOnGarmin = "/Volumes/GARMIN/" # NEED TO COMBINE with copy files over
oldTEMPfiles   = baseFolderGPX + "old TEMP files/" # for files created on day of download which may not be complete

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
    puts "\n36. Processing files from #{folderOnGarmin} and also coping those files to #{folderDownload}  +_+_+_+_+_+_+_+_+_+_+_+_\n"
  else
    puts "\n38. Processing files from #{folderDownload}\n\nor XXXXXXXXXXXXXXXX FORGOT TO CONNECT GARMIN XXXXXXXXXXXXXXXXXXX\n"
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
  puts "\n71. Copying over original files to computer from Garmin:(#{folderOnGarmin}\n"
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
      # puts "135. fNotToday: #{fNotToday}\n\n"
      # puts "136. today: #{today}  File.basename: #{File.basename(fx, ".*")}. \n\n"
        if !File.exists?(fNotToday) # this goes through all the files on the Garmin  
        if today!=File.basename(fx, ".*")
          i += 1
          FileUtils.cp fx, fNotToday 
          puts "89. \"#{fx}\" copied to "#{fNotToday}\"\n"
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
  puts "\n100. Copying finished. #{i} gpx files copied from Garmin to #{baseFolderGPX}…\n\n"  
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

def copyRename(baseFolderGPX, folderDownload) # from Year Downloads to Year Massaged folder and create list of those new files
  newFiles = []
  Find.find(folderDownload) do |fx|
    puts "116. fx: #{fx}. File.file?(fx): #{File.file?(fx)}. "
    Find.prune if !File.file?(fx) # the directory we're looking in is added to the fx list, so skip it
    puts "118. fx: #{fx}"
    # Find.prune if  File.exist?(fx)  # checking if file to be processed exists. Probably not needed now as only working with a list of existing files
    Find.prune if File.extname(fx) != '.gpx' # get errors trying to process other files on card.
    puts "121. fx: #{fx}. File.basename(fx): #{File.basename(fx)}\n"
  
    i = 0
    # Establish file name
    yearFile  = File.basename(fx)[0,4]
    # fileshortnew = "#{yearFile}.#{File.basename(fx)[4,2]}.#{File.basename(fx)[6,2]}"
    #  moved to method
    fileshortnew = dotInName(fx,yearFile)
    # puts "175. File.basename(fx): #{File.basename(fx)}. yearFile: #{yearFile}. fileshortnew: #{fileshortnew} \n"
    folderNew = "#{baseFolderGPX}#{yearFile} Massaged"
    # puts "182. fnew: #{fnew}  ============================\n"
    puts "131. today: #{today}.==File.basename(fx, ".TEMP.gpx"): #{File.basename(fx, ".TEMP.gpx")}."
    if today==File.basename(fx, ".TEMP.gpx")
      puts "186 fx: #{fx}. "
      # Not clear why originally was using timeshifted, seems should just be original filename with TEMP added
      # fileshortnew = timeshifted.strftime("%Y.%m.%d") + ".TEMP" # formatting filename
      fileshortnew = dotInName(fx,yearFile) + ".TEMP" 
      #  year is timeshifted. Not sure whey 
      # fnew = "#{baseFolderGPX}#{year} Massaged/#{fileshortnew}.gpx"
      fnew = "#{folderNew}/#{fileshortnew}.gpx"
      # fileTEMP = true
    else # all but today's file
      fnew = "#{folderNew}/#{fileshortnew}.gpx"
      # fileTEMP = false
    end # today==
    if !File.exists?(fnew)
      newFiles << fnew
      FileUtils.cp(fx, fnew) 
      i =+ 1
    end  
    puts "\n149. Copying and renaming finished. #{i} gpx files copied to #{folderNew}.\n\n" 
    puts "\n150. newFiles: #{newFiles}"
   end 
return newFiles   
end # Copy and rename files from Year Downloads to Year Massaged folder and create list of those new files


# ================= End of defs and beginning of actions ##############################

getRubyVersion("./\.ruby-version") # for testing can turn this on and off. Couldn't make it work when file name was not passed in. 

# Determine if Garmin is mounted, and if not just process from folderDownload
fromWhichFolder = garminOrFolder(folderOnGarmin,folderDownload)

# Remove TEMP files from folderDownload and folderMassaged. These are files created on the day of previous download and may be incomplete
removeDayOf(folderDownload,folderMassaged, oldTEMPfiles)

# Copy gpx files from Garmin to Year Download folder, if that option is selected
copyFiles(folderOnGarmin, baseFolderGPX) if fromWhichFolder == folderOnGarmin

# ejectGarmin(folderDownload) # not working. Run to see errors. Not critical, so will move on for now FIX

# Move and rename files from folderDownload to folderMassaged
newFiles = copyRename(baseFolderGPX, folderDownload)  

# Process files, i.e., adding annotations and locations to the "names". 
# NOW HAVE TO SEPARATE OUT WHICH FILES ARE NEW AND WHICH ARE OLD.                                          KEEP TRACK OF THE FILES THAT HAVE MOVED, JUST CREATE AN ARRAY AND GO THRU THEM !!!!!'






#  Trying to find a way to get the line number of the script. Would be handy for debugging
# echo "Left:  »${TM_CURRENT_LINE:0:TM_LINE_INDEX}«"
# puts $TM_LINE_INDEX # doesn't do anything
# echo "Right: »${TM_CURRENT_LINE:TM_LINE_INDEX}«"
# puts "\nTM_LINE_INDEX: #{$TM_LINE_INDEX}. ${TM_CURRENT_LINE:0:TM_LINE_INDEX}" # first part is blank, 
# ++++++++++================ Test stuff
# puts "ENV[\"PATH\"]: #{ENV['PATH']}"


