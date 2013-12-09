#!/usr/bin/env ruby
require 'geonames'

# to report the Ruby version the script is running
require "/Users/gscar/Dropbox/scriptsEtc/rubyVersionMethod.rb"
rubyVersion(File.dirname(__FILE__))

places_nearby = Geonames::WebService.find_nearby_place_name 43.900120387, -78.882869834
puts "places_nearby: #{places_nearby}"

# Call to Geonames no longer works, come up empty, no error