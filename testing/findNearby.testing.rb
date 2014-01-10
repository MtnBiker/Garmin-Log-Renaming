# require './lib/geonames'
require 'geonames'

geoNamesUser = "geonames@web.knobby.ws"
api = api = GeoNames.new(username: geoNamesUser)

testLoc = "lat: 33.81222, lng: -118.38361"
testLat = 33.81222
testLng = -118.38361

# Zillow doesn't do this one, i.e., neighbourhood
# testLat =   33.793038,
# testLng = -118.327683

# testLat =   33.836603
# testLng = -118.377645
 {"geonames"=>[{"countryId"=>"6252001", "adminCode1"=>"CA", "countryName"=>"United States", "fclName"=>"spot, building, farm", "countryCode"=>"US", "lng"=>"-118.37273", "fcodeName"=>"school", "distance"=>"0.45696", "toponymName"=>"Bishop Montgomery High School", "fcl"=>"S", "name"=>"Bishop Montgomery High School", "fcode"=>"SCH", "geonameId"=>5328829, "lat"=>"33.83699", "adminName1"=>"California", "population"=>0}]}

# 
# testLat =   33.83
# testLng = -118.37


nearby = api.find_nearby(lat: testLat, lng: testLng).first
puts "\n25. find_nearby: \n#{nearby}\n"
puts "\n22. name, city, adminName2, adminCode1: #{nearby['name']}, #{nearby['city']}, #{nearby['adminName2']}, #{nearby['adminCode1']} for #{testLat}, #{testLng}" 
puts "27. nearby['countryName']: #{nearby['countryName']}. nearby['distance']: #{nearby['distance']}."
# puts "\n28. nearby['geonames']: \n#{nearby['geonames']}" # gets rid of the key, geonames as expected
nearbyToponymName = api.find_nearby(lat: testLat, lng: testLng).first["toponymName"]
puts "32. nearbyToponymName: #{nearbyToponymName}."

# geonamesNearby = nearby['geonames'].to_s
# puts "geonamesNearby['geonamesNearby['name']']: #{geonamesNearby['name']}" # error because brackets [] surround, if strip them then have a string, maybe could convert back to array? Didn't work. See below
# puts "26. geonamesNearby: #{geonamesNearby}"
# puts "27. geonamesNearby[1...-1]: #{geonamesNearby[1...-1]}"
# puts nearby['geonames'].to_s[1...-1].to_a

# puts "\n31. nearby.first.adminName2: #{nearby.first.adminName2}" #error

# extended_find_nearby
# extentedFindNearby = api.extended_find_nearby(lat: testLat, lng: testLng)
# puts "/n35. extentedFindNearby: #{extentedFindNearby}" # => XML queries haven't been implemented

# find_nearby_place_name
find_nearby_place_name = api.find_nearby_place_name(lat: testLat, lng: testLng).first
puts "\n42. find_nearby_place_name: \n#{find_nearby_place_name}" # =>  [{"countryId"=>"6252001", "adminCode1"=>"CA", "countryName"=>"United States", "fclName"=>"city, village,...", "countryCode"=>"US", "lng"=>"-118.3798", "fcodeName"=>"populated place", "distance"=>"1.02747", "toponymName"=>"Clifton", "fcl"=>"P", "name"=>"Clifton", "fcode"=>"PPL", "geonameId"=>5338011, "lat"=>"33.82752", "adminName1"=>"California", "population"=>0}]
puts find_nearby_place_name['toponymName']

find_nearby_wikipedia = api.find_nearby_wikipedia(lat: testLat, lng: testLng)
puts "\n46. find_nearby_wikipedia: \n#{find_nearby_wikipedia}"
puts "\n47. find_nearby_wikipedia[geonames]: \n#{find_nearby_wikipedia["geonames"]}"
puts "\n48. find_nearby_wikipedia[geonames].first: \n#{find_nearby_wikipedia["geonames"].first}\n\n"
# find_nearby_wikipedia_geonames_first = find_nearby_wikipedia["geonames"].first
# puts find_nearby_wikipedia_geonames_first
# puts find_nearby_wikipedia_geonames_first["title"]
puts "\n52. find_nearby_wikipedia_geonames_first[title]: \n#{find_nearby_wikipedia_geonames_first["title"]}."
puts "\n53. find_nearby_wikipedia[geonames].first[title]: \n#{find_nearby_wikipedia["geonames"].first["title"]}"

#  find_nearby_wikipedia
find_nearby_wikipedia_first = api.find_nearby_wikipedia(lat: testLat, lng: testLng).first
puts "\n50. find_nearby_wikipedia_first: \n#{find_nearby_wikipedia_first}" # =>  [{"countryId"=>"6252001", "adminCode1"=>"CA", "countryName"=>"United States", "fclName"=>"city, village,...", "countryCode"=>"US", "lng"=>"-118.3798", "fcodeName"=>"populated place", "distance"=>"1.02747", "toponymName"=>"Clifton", "fcl"=>"P", "name"=>"Clifton", "fcode"=>"PPL", "geonameId"=>5338011, "lat"=>"33.82752", "adminName1"=>"California", "population"=>0}]
# puts find_nearby_wikipedia_first['name'] # fails currently 2014.01.09
# ["geonames", [{"summary"=>"Bishop Montgomery High School (commonly referred to as \"BMHS\" or simply \"Bishop\" by students) is a Catholic high school serving twenty-five parishes in the Roman Catholic Archdiocese of Los Angeles. BMHS was founded in 1957, and staffed by the Sisters of St (...)", "distance"=>"0.5055", "rank"=>83, "title"=>"Bishop Montgomery High School", "wikipediaUrl"=>"en.wikipedia.org/wiki/Bishop_Montgomery_High_School", "elevation"=>38, "countryCode"=>"US", "lng"=>-118.37222222222222, "feature"=>"edu", "geoNameId"=>5328829, "lang"=>"en", "lat"=>33.83722222222222}, {"summary"=>"Redondo Union High School is a public high school in Redondo Beach, California. Redondo Union High School is a part of the Redondo Beach Unified School District. All residents of Redondo Beach are zoned to Redondo Union (...)", "distance"=>"1.2118", "rank"=>94, "title"=>"Redondo Union High School", "wikipediaUrl"=>"en.wikipedia.org/wiki/Redondo_Union_High_School", "elevation"=>38, "countryCode"=>"US", "lng"=>-118.384611, "feature"=>"edu", "lang"=>"en", "lat"=>33.845839}, {"summary"=>"Beach Cities Health District (BCHD) is a government agency dedicated to providing preventive health services to the community. Formed in 1955, it is the special-purpose district responsible for the improving the health of the citizens of Hermosa Beach, Manhattan Beach, and Redondo Beach (...)", "distance"=>"1.7713", "rank"=>87, "title"=>"Beach Cities Health District", "wikipediaUrl"=>"en.wikipedia.org/wiki/Beach_Cities_Health_District", "elevation"=>53, "countryCode"=>"US", "lng"=>-118.37888888888888, "feature"=>"landmark", "lang"=>"en", "lat"=>33.8525}, {"summary"=>"Tulita Elementary School is located in Redondo Beach, California, United States. It's one of 8 elementary schools in the Redondo Beach Unified School District. Students attend Kindergarten through 5th grade (as of 2010) and then typically go on to Parras Middle School, and then to Redondo Union High (...)", "distance"=>"1.7881", "rank"=>8, "title"=>"Tulita Elementary School", "wikipediaUrl"=>"en.wikipedia.org/wiki/Tulita_Elementary_School", "elevation"=>29, "countryCode"=>"US", "lng"=>-118.37638888888888, "feature"=>"landmark", "geoNameId"=>5403871, "lang"=>"en", "lat"=>33.82055555555556}, {"summary"=>"Bert Lynn Middle School is a public middle school in Torrance, California. Bert Lynn covers grades 6th through 8th. For over seven years, the Bert Lynn Learning community has shown top academic scores. In addition to strong academic scores, Bert Lynn Middle School has been recognized at both the (...)", "distance"=>"2.0793", "rank"=>54, "title"=>"Bert Lynn Middle School", "wikipediaUrl"=>"en.wikipedia.org/wiki/Bert_Lynn_Middle_School", "elevation"=>33, "countryCode"=>"US", "lng"=>-118.36332, "feature"=>"edu", "lang"=>"en", "lat"=>33.85103}]]


puts 


# nearbyName = api.find_nearby(lat: testLat, lng: testLng, "name")
# puts "31. nearbyName: #{nearbyName}"

# http://api.geonames.org/findNearbyJSON?lat=33.836603&lng=-118.377645&username=demo 
# http://api.geonames.org/findNearbyJSON?lat=47.3&lng=9&username=demo 
# {"geonames":[{"countryId":"6252001","adminCode1":"CA","countryName":"United States","fclName":"spot, building, farm","countryCode":"US","lng":"-118.37273","fcodeName":"school","distance":"0.45696","toponymName":"Bishop Montgomery High School","fcl":"S","name":"Bishop Montgomery High School","fcode":"SCH","geonameId":5328829,"lat":"33.83699","adminName1":"California","population":0}]}


# findnearby Wikipedia
# http://api.geonames.org/findNearbyWikipediaJSON?lat=33.836603&lng=-118.377645&username=demo
# {"geonames":[{"summary":"Bishop Montgomery High School (commonly referred to as \"BMHS\" or simply \"Bishop\" by students) is a Catholic high school serving twenty-five parishes in the Roman Catholic Archdiocese of Los Angeles. BMHS was founded in 1957, and staffed by the Sisters of St (...)","distance":"0.5055","rank":83,"title":"Bishop Montgomery High School","wikipediaUrl":"en.wikipedia.org/wiki/Bishop_Montgomery_High_School","elevation":38,"countryCode":"US","lng":-118.37222222222222,"feature":"edu","geoNameId":5328829,"lang":"en","lat":33.83722222222222},{"summary":"Redondo Union High School is a public high school in Redondo Beach, California. Redondo Union High School is a part of the Redondo Beach Unified School District. All residents of Redondo Beach are zoned to Redondo Union (...)","distance":"1.2118","rank":94,"title":"Redondo Union High School","wikipediaUrl":"en.wikipedia.org/wiki/Redondo_Union_High_School","elevation":38,"countryCode":"US","lng":-118.384611,"feature":"edu","lang":"en","lat":33.845839},{"summary":"Beach Cities Health District (BCHD) is a government agency dedicated to providing preventive health services to the community. Formed in 1955, it is the special-purpose district responsible for the improving the health of the citizens of Hermosa Beach, Manhattan Beach, and Redondo Beach (...)","distance":"1.7713","rank":87,"title":"Beach Cities Health District","wikipediaUrl":"en.wikipedia.org/wiki/Beach_Cities_Health_District","elevation":53,"countryCode":"US","lng":-118.37888888888888,"feature":"landmark","lang":"en","lat":33.8525},{"summary":"Tulita Elementary School is located in Redondo Beach, California, United States. It's one of 8 elementary schools in the Redondo Beach Unified School District. Students attend Kindergarten through 5th grade (as of 2010) and then typically go on to Parras Middle School, and then to Redondo Union High (...)","distance":"1.7881","rank":8,"title":"Tulita Elementary School","wikipediaUrl":"en.wikipedia.org/wiki/Tulita_Elementary_School","elevation":29,"countryCode":"US","lng":-118.37638888888888,"feature":"landmark","geoNameId":5403871,"lang":"en","lat":33.82055555555556},{"summary":"Bert Lynn Middle School is a public middle school in Torrance, California. Bert Lynn covers grades 6th through 8th. For over seven years, the Bert Lynn Learning community has shown top academic scores. In addition to strong academic scores, Bert Lynn Middle School has been recognized at both the (...)","distance":"2.0793","rank":54,"title":"Bert Lynn Middle School","wikipediaUrl":"en.wikipedia.org/wiki/Bert_Lynn_Middle_School","elevation":33,"countryCode":"US","lng":-118.36332,"feature":"edu","lang":"en","lat":33.85103}]}