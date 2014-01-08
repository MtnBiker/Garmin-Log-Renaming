require './lib/geonames'

api = GeoNames.new

testLoc = "lat: 33.81222, lng: -118.38361"
testLat = 33.81222
testLng = -118.38361
#  => neigh: {"adminName2"=>"Los Angeles County", "adminCode2"=>"037", "adminCode1"=>"CA", "countryName"=>"United States", "name"=>"Hollywood Riviera", "countryCode"=>"US", "city"=>"Torrance", "adminName1"=>"California"}

#  neighborhood fails for this
testLat =   33.836603
testLng = -118.377645
#  => in `<main>': undefined method `[]' for nil:NilClass (NoMethodError)

# # but works for this and doesn't work until get to 2 significant digits her 
testLat =   33.83
testLng = -118.37
# => neigh: {"adminName2"=>"Los Angeles County", "adminCode2"=>"037", "adminCode1"=>"CA", "countryName"=>"United States", "name"=>"West Torrance", "countryCode"=>"US", "city"=>"Torrance", "adminName1"=>"California"}

# => neighbourhood: {"adminName2"=>"Los Angeles County", "adminCode2"=>"037", "adminCode1"=>"CA", "countryName"=>"United States", "name"=>"Hollywood Riviera", "countryCode"=>"US", "city"=>"Torrance", "adminName1"=>"California"}

neigh = api.neighbourhood(lat: testLat, lng: testLng)
puts "\n23. neigh: #{neigh}\n"
# puts "\nname, city, adminName2, adminCode1: #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']} for #{testLat}, #{testLng}" 

# http://api.geonames.org/findNearbyPlaceNameJSON?lat=33.836603&lng=-118.377645&username=demo 
#  {"geonames":[{"countryId":"6252001","adminCode1":"CA","countryName":"United States","fclName":"city, village,...","countryCode":"US","lng":"-118.3798","fcodeName":"populated place","distance":"1.02747","toponymName":"Clifton","fcl":"P","name":"Clifton","fcode":"PPL","geonameId":5338011,"lat":"33.82752","adminName1":"California","population":0}]}

#  w/o JSON: 
# <geonames>
# <geoname>
# <toponymName>Clifton</toponymName>
# <name>Clifton</name>
# <lat>33.82752</lat>
# <lng>-118.3798</lng>
# <geonameId>5338011</geonameId>
# <countryCode>US</countryCode>
# <countryName>United States</countryName>
# <fcl>P</fcl>
# <fcode>PPL</fcode>
# <distance>1.02747</distance>
# </geoname>
# </geonames>