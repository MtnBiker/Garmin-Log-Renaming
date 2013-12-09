# set diskName to "GARMIN"
# tell application "Finder"
#     if disk diskName exists then
#     eject disk diskName
#   end
# end

# https://github.com/mattneub/appscript/tree/master/rb-appscript
#!/usr/bin/env ruby
# require 'rubygems'
# =====================
require 'Appscript'
require '/Users/gscar/Dropbox/scriptsEtc/Garmin Log renaming/sdefToRBAppscriptModule.rb'
f = FindApp.by_id('com.apple.finder')

Finder = SDEFParser.makeModule(f)
finder = Appscript.app("Finder", Finder)

puts finder.eject("GARMIN")
# ===============================
# Scripting Bridge

# require "osx/cocoa" # cannot find
# include OSX
# OSX.require_framework 'ScriptingBridge'
# 
# iTunes = OSX::SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")
# 
# puts iTunes.currentTrack.name

# require "osx/cocoa"
# include OSX
# OSX.require_framework 'ScriptingBridge'
# 
# finder = OSX::SBApplication.applicationWithBundleIdentifier_("com.apple.Finder")
# 
# puts Finder.eject("GARMIN")