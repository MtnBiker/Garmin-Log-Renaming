# Garmin Log Renaming

Renames Garmin 60CSx files to current date with hyphens to distinguish from original files and for readablility. And annotates the <name> field

First copies files from Garmin to a folder on the Mac, then copies and renames those files to another folder (Massaged) and then annotates the <name> field with location and easy to read dates. 

Corrects for Daylight Saving Time.

The files in the Massaged folder are named (dated) using local time, since that is what is really in the file.

## Usage

Garmin in mounted and connected via USB. Change folder names to suit at beginning of script and run script..

## About

Written by MtnBiker who knows little about how Ruby works. You are forewarned. 

The script is probably very specific to what I want and somewhat to the specific GPSr that I use.

## Dependencies

This library depends on geonames-wrapper which depends on addressable and tzinfo. 
See https://github.com/manveru/geonames for information on the primary driver for this script. Thank you Michael Fellinger.

Works with Ruby 1.9 and 2.0. Probably not with 1.8.7.

### Licensing

I have no idea. Use at your own risk.