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
  TODO fix time zone error. Shows -7 during standard time in Calif.  Not seeing this now 2013.01.07. Maybe wait for daylight time to see if there is a problem
=end
# .c an attempt at a rewrite using Classes. Deleted everything but file locations. Will cover over from previous version, but will rather than patching copying will make me think about how good the good is.
# .d now using geoname.rb which needs 1.9 which also meant some updating since parsedate was gone. Previous was https://github.com/manveru/geonames

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
getRubyVersion("./\.ruby-version") # for testing can turn this on and off. Couldn't make it work when file name was not passed in. 

#  Trying to find a way to get the line number of the script. Would be handy for debugging
# echo "Left:  »${TM_CURRENT_LINE:0:TM_LINE_INDEX}«"
puts $TM_LINE_INDEX # doesn't do anything
# echo "Right: »${TM_CURRENT_LINE:TM_LINE_INDEX}«"
puts "TM_LINE_INDEX: #{$TM_LINE_INDEX}. ${TM_CURRENT_LINE:0:TM_LINE_INDEX}" # first part is blank, 
# ++++++++++================ Test stuff
# puts "ENV[\"PATH\"]: #{ENV['PATH']}"


