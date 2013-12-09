# seems to need 1.9
#  the following three come with geonames.rb
# require 'json'
# require 'open-uri'
# require 'addressable/template'
require './lib/geonames'

api = GeoNames.new
puts "api: #{api}"
ocean = api.ocean(lat: 0, lng: 0)
puts "ocean: #{ocean}"
# oceanName = ocean(:name)
# puts oceanName
testLoc = "lat: 33.81222, lng: -118.38361"
testLat = 33.81222
testLng = -118.38361
country = api.country_code(lat: testLat, lng: testLng)
puts "country: #{country}"
puts "\ncountry['countryName']: #{country['countryName']}"

extFind = api.find_nearby(lat: testLat, lng: testLng)
puts "\n795. find_nearby: #{extFind}"
puts "Note that find_nearby is a hash inside an array or the opposite or what?"
puts "\nfind_nearby['countryName']: #{extFind['countryName']}"
puts "\nfind_nearby['name']: #{extFind['name']}. find_nearby['toponymName']: #{extFind['toponymName'] }"


place = api.find_nearby_place_name(lat: testLat, lng: testLng)
puts "\nplace: #{place}"
puts "\nplace[0]: #{place[0]}"
place = place[0]
place['countryName']
puts "\n find_nearby_place_name['countryName']: #{place['countryName']}"

puts "\nplace[0]['name']: #{place['name']}\n place[0]['toponymName']: #{place['toponymName']}\nadminName1:  #{place['adminName1']}"

street = api.find_nearby_postal_codes(lat: testLat, lng: testLng)
puts "\nfind_nearby_postal_codes: #{street}"
puts "\nfind_nearby_postal_codes[0]['placeName']: #{street[0]['placeName']}"

# puts "\nextended_find_nearby: #{api.extended_find_nearby(lat: testLat, lng: testLng)}" # NotImplementedError: XML queries haven't been implemented.
# puts "\nfind_nearby_streets: #{api.find_nearby_streets(testLat, testLng)}"
# puts "\n #{api.find_nearby_streets(testLat, testLng)[0]['fraddr']} #{api.find_nearby_streets(testLat, testLng)[0]['name']}, #{api.find_nearby_streets(testLat, testLng)[0]['placename']}, #{api.find_nearby_streets(testLat, testLng)[0]['adminCode1']}, #{api.find_nearby_streets(testLat, testLng)[0]['postalcode']}"
# puts "\n find_nearby_streets_osm[0]: #{api.find_nearby_streets_osm(testLat, testLng)}"
# find_nearby_streets_osm[0] . Note that this is a comment: {"streetSegment"=>[{"distance"=>"0.04", "highway"=>"residential", "name"=>"Paseo de Las Delicas", "line"=>"-118.383707 33.814615,-118.3832784 33.8137845,-118.3833267 33.8131516,-118.3833696 33.812541,-118.3834554 33.8118546", "wayId"=>"13462604"}, {"distance"=>"0.04", "highway"=>"residential", "name"=>"Calle Miramar", "line"=>"-118.385543 33.8113694,-118.3844961 33.8116986,-118.3834554 33.8118546,-118.382463 33.81181,-118.3819748 33.8117119,-118.3816369 33.8115961,-118.3811702 33.8114178,-118.380328 33.8108606", "wayId"=>"46983708"}, {"distance"=>"0.04", "highway"=>"residential", "name"=>"Via Estrellita", "line"=>"-118.3833696 33.812541,-118.382463 33.81181", "wayId"=>"13439629"}, {"distance"=>"0.1", "highway"=>"residential", "name"=>"Via Monte D Oro", "line"=>"-118.384807 33.814715,-118.3845551 33.8142213,-118.3843942 33.813887,-118.3843298 33.8136018,-118.384303 33.8133299,-118.3844961 33.8116986,-118.384707 33.810515,-118.3846785 33.8103258,-118.3846892 33.8099157,-118.3846195 33.8097062,-118.3845551 33.8095636,-118.3844049 33.8093719,-118.3842601 33.8092471,-118.3839919 33.8091134,-118.3837344 33.8090599,-118.3835037 33.8089841,-118.3832516 33.8088861,-118.383007 33.808715,-118.382607 33.808215,-118.3817871 33.8074954,-118.3817227 33.8073617,-118.381653 33.8072012,-118.3816154 33.8070274,-118.3815993 33.8068402,-118.3815993 33.8067644,-118.3817334 33.806439,-118.3820124 33.8061002", "wayId"=>"13416311"}, {"distance"=>"0.14", "highway"=>"residential", "name"=>"Calle Mayor", "line"=>"-118.3893294 33.8082843,-118.388707 33.807915,-118.3883424 33.8077138,-118.3881385 33.8076603,-118.3878489 33.8076692,-118.387507 33.807815,-118.387173 33.8080436,-118.386894 33.8083735,-118.3863897 33.8090153,-118.386107 33.809415,-118.3858748 33.8095948,-118.3852847 33.8101118,-118.384707 33.810515,-118.3841903 33.8107715,-118.3837451 33.8109186,-118.3833052 33.8109899,-118.3828278 33.8109988,-118.380328 33.8108606,-118.3795447 33.8108071,-118.3790727 33.8107626,-118.3787401 33.8106913,-118.3784719 33.8105754,-118.3782144 33.8104773,-118.3778281 33.8103882,-118.3772863 33.810357,-118.3763797 33.8104684,-118.3757146 33.8106645,-118.3746442 33.8111004,-118.3744296 33.8111806,-118.3739146 33.8114837,-118.3738013 33.8115683,-118.3729066 33.8122366,-118.3728036 33.8123008,-118.372692 33.812365,-118.3725461 33.8124363,-118.3723744 33.8125005,-118.3721513 33.8125575,-118.371911 33.8125932,-118.3716277 33.8126288,-118.3712243 33.8126716,-118.3709926 33.8127001,-118.3707952 33.8127429,-118.3705458 33.8128119,-118.3703145 33.8129283,-118.3700914 33.8130496,-118.3697566 33.8132849,-118.3695249 33.8134347,-118.368545 33.8138446,-118.3673327 33.8143527,-118.366606 33.814715,-118.3657985 33.8150837,-118.3646397 33.8156007,-118.3632553 33.8162511,-118.3624383 33.8166331,-118.3618053 33.8168916,-118.3613965 33.8170257,-118.3610451 33.8170355,-118.3598761 33.8170091,-118.3588354 33.817018,-118.3580201 33.8170091,-118.3576016 33.8168397", "wayId"=>"13289942"}, {"distance"=>"0.14", "highway"=>"residential", "name"=>"Via Linda Vista", "line"=>"-118.3832784 33.8137845,-118.3827419 33.8132318,-118.3821197 33.812697,-118.381433 33.8122334,-118.3806498 33.8118991,-118.3804835 33.8118546,-118.3801885 33.8117743,-118.3799364 33.8117342,-118.3796145 33.8117075,-118.3791961 33.811703,-118.3787186 33.8117164,-118.378327 33.8118412,-118.3780159 33.8119526,-118.3777208 33.8121042,-118.377517 33.8122423,-118.3771844 33.8125499,-118.376943 33.8128663,-118.3768196 33.8131427,-118.3767606 33.8133388,-118.376706 33.813515", "wayId"=>"13440755"}, {"distance"=>"0.2", "highway"=>"residential", "name"=>"Camino de Las Colinas", "line"=>"-118.3851398 33.8148141,-118.385543 33.8113694,-118.3855537 33.8111019,-118.385602 33.8107989,-118.3857093 33.8103933,-118.3858855 33.8099246,-118.386107 33.809415", "wayId"=>"46342241"}, {"distance"=>"0.23", "highway"=>"residential", "name"=>"Via la Selva", "line"=>"-118.3845551 33.8095636,-118.3844317 33.8096215,-118.3841581 33.8097998,-118.3838577 33.8099558,-118.3835842 33.8100583,-118.3832462 33.8101475,-118.382919 33.8101831,-118.3824898 33.8101831,-118.3812345 33.8101386,-118.3809127 33.8101876,-118.3806605 33.8102678", "wayId"=>"13308559"}, {"distance"=>"0.2", "highway"=>"residential", "name"=>"Calle Miramar", "line"=>"-118.3881554 33.8116324,-118.3879999 33.8114897,-118.3877424 33.8113694,-118.387442 33.811307,-118.3871845 33.8112936,-118.386927 33.8113114,-118.3867875 33.8113159,-118.3863423 33.8112936,-118.3859453 33.8113337,-118.385661 33.8113917,-118.385543 33.8113694", "wayId"=>"13336790"}, {"distance"=>"0.2", "highway"=>"residential", "name"=>"Calle Miramar", "oneway"=>"true", "line"=>"-118.3896467 33.8152024,-118.3894322 33.815042,-118.3891264 33.8148905,-118.3888474 33.8146676,-118.3886114 33.8143957,-118.3884988 33.8141863,-118.3884183 33.8139099,-118.3884558 33.8120469,-118.3884022 33.8117661,-118.3882936 33.8115893,-118.3880589 33.8113828,-118.3877853 33.8112535,-118.3874695 33.8111992,-118.3871845 33.8111911,-118.3868122 33.8112005,-118.3863208 33.8112045,-118.3859024 33.8112401,-118.3856342 33.8112892,-118.385543 33.8113694", "wayId"=>"46983684"}]}

# puts "\nfind_nearest_address: #{api.find_nearest_address(lat: testLat, lng: testLng)}. Note Street Number is wrong for 245 PDLDk"
# 
# => find_nearest_address: {"address"=>{"postalcode"=>"90277", "adminCode2"=>"037", "adminCode1"=>"CA", "street"=>"Pso de Las Delicias", "countryCode"=>"US", "lng"=>"-118.38339", "placename"=>"Torrance", "adminName2"=>"Los Angeles", "distance"=>"0.02", "streetNumber"=>"273", "mtfcc"=>"S1400", "lat"=>"33.8122", "adminName1"=>"California"}}. Note Street Number is wrong for 253 Paseo de las Delicias
# puts "\nneighbourhood: #{api.neighbourhood(lat: testLat, lng: testLng)}. Note has Hollywood Riviera and Torrance, but not Redondo Beach"

# => neighbourhood: {"adminName2"=>"Los Angeles County", "adminCode2"=>"037", "adminCode1"=>"CA", "countryName"=>"United States", "name"=>"Hollywood Riviera", "countryCode"=>"US", "city"=>"Torrance", "adminName1"=>"California"}
# api = GeoNames.new
neigh = api.neighbourhood(lat: testLat, lng: testLng)
puts "name, city, adminName2, adminCode1: #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}" 


timeZ = api.timezone(lat: testLat, lng: testLng)
# => timeZ: {"time"=>"2013-11-11 09:19", "countryName"=>"United States", "sunset"=>"2013-11-11 16:52", "rawOffset"=>-8, "dstOffset"=>-7, "countryCode"=>"US", "gmtOffset"=>-8, "lng"=>-118.38361, "sunrise"=>"2013-11-11 06:21", "timezoneId"=>"America/Los_Angeles", "lat"=>33.81222}
puts "timeZ: #{timeZ}. {timeZ['gmtOffset']}"