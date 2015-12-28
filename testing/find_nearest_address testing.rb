require 'geonames'

geoNamesUser = "geonames@web.knobby.ws"
api = GeoNames.new(username: geoNamesUser)

def placeInfo(api, latIn, longIn)
  sigPlace = api.find_nearby_wikipedia(lat: latIn, lng: longIn)["geonames"].first["title"]
  distance = api.find_nearby_wikipedia(lat: latIn, lng: longIn)["geonames"].first["distance"]
  nearbyToponymName = api.find_nearby(lat: latIn, lng: longIn).first["toponymName"]
  countryCode = api.country_code(lat: latIn, lng: longIn)
  find_nearest_address = api.find_nearest_address(lat: latIn, lng: longIn)["address"]
  puts "\n\n11. \nfind_nearest_address: #{find_nearest_address}.\n"
  puts "\n12. #{find_nearest_address["streetNumber"]} #{find_nearest_address["street"]},  #{find_nearest_address["placename"]}, #{find_nearest_address["adminName2"]} County, #{find_nearest_address["adminName1"]}" 

# return "#{sigPlace}, #{nearbyToponymName}, #{countryCode['name']}, #{countryCode['adminName1']}, #{countryCode['countryName']}" # doesn't give much information
return "#{sigPlace} (#{distance[0..3]}km), #{nearbyToponymName}, #{find_nearest_address["placename"]}, #{find_nearest_address["adminName2"]} County, #{find_nearest_address["adminName1"]}, #{countryCode['countryName']}" # find_nearest_address["countryCode"] could be used but only is the code, e.g. US, instead of spelled out

end
puts placeInfo(api, "33.793038", "-118.327683") # Robinson Helicopter Company, South Bay Oriental Mission Church, ,  United States.
puts placeInfo(api, "33.792004", "-118.328489") # West Torrance, Torrance, Los Angeles County, CA. Sometimes
puts placeInfo(api, "33.792702", "-118.328932")
puts placeInfo(api, "33.812183", "-118.383752")

