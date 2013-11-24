# seems to need 1.9
require 'json'
require 'open-uri'
require 'addressable/template'

class GeoNames
  OPTIONS = {
    host: 'ws.geonames.org',
    time_format: '%Y-%m-%d %T %z',
    timezone: 'UTC',
    username: nil,
  }

  QUERY = {}

  attr_reader :options, :uris

  def initialize(options = {})
    @options = OPTIONS.merge(options)
    @uris = Hash[QUERY.map{|name, args|
      if args.empty?
        template = Addressable::Template.new(
          "http://{host}/#{name}JSON"
        )
      else
        joined = args.flatten.uniq.sort.join(',')
        template = Addressable::Template.new(
          "http://{host}/#{name}JSON{?#{joined}}"
        )
      end
      [name, template]
    }]
  end

  # Execute query for given +name+ with +parameters+ translated via URI
  # template expansion.
  def query(name, parameters)
    default = {host: options[:host]}
    default[:username] = options[:username] if options[:username]

    uri = uris[name].expand(default.merge(parameters))

    if block_given?
      open(uri.to_s){|io| yield(io.read) }
    else
      open(uri.to_s){|io| JSON.parse(io.read) }
    end
  end

  # Utility method for some queries that return times, we convert them to real
  # Time instances with proper UTC timezone.
  def fix_datetime(hash)
    if time = hash['datetime']
      zone, format = options.values_at(:timezone, :time_format)
      hash['datetime'] = Time.strptime("#{time} #{zone}", format)
    end

    hash
  end

  # Returns the attribute of the geoNames feature with the given geonameId
  #
  # Parameters: geonameId
  #
  # Example:
  #
  #   api.get(geonameId: 2643743)
  def get(parameters)
    query(:get, parameters)
  end
  QUERY[:get] = %w[geonameId]

  # Returns a list of recent earthquakes, ordered by magnitude
  #
  # north, south, east, west: coordinates of bounding box
  # callback: name of javascript function (optional parameter)
  # date: date of earthquakes 'yyyy-MM-dd', optional parameter
  # minMagnitude: minimal magnitude, optional parameter
  # maxRows: maximal number of rows returned (default = 10)
  #
  # Example:
  #
  #   api.earthquakes(north: 44.1, south: -9.9, east: -22.4, west: 55.2)
  def earthquakes(parameters = {})
    quakes = query(:earthquakes, parameters)['earthquakes']
    quakes.map{|quake| fix_datetime(quake) }
  end
  QUERY[:earthquakes] = %w[
    north south east west date callback minMagnitude maxRows
  ]

  # Elevation - Aster Global Digital Elevation Model
  #
  # Parameters: lat,lng
  #
  # Sample area: ca 30m x 30m, between 83N and 65S latitude.
  # Result: a single number giving the elevation in meters according to aster
  # gdem, ocean areas have been masked as "no data" and have been assigned a
  # value of -9999.
  #
  # Example:
  #
  #   api.astergdem(lat: 50.01, lng: 10.2)
  def astergdem(parameters = {})
    query(:astergdem, parameters)
  end
  QUERY[:astergdem] = %w[lat lng]

  # GTOPO30 is a global digital elevation model (DEM) with a horizontal grid
  # spacing of 30 arc seconds (approximately 1 kilometer). GTOPO30 was derived
  # from several raster and vector sources of topographic information.
  #
  # Parameters: lat,lng
  #
  # Sample area: ca 1km x 1km Result : a single number giving the elevation in
  # meters according to gtopo30, ocean areas have been masked as "no data" and
  # have been assigned a value of -9999.
  #
  # Example:
  #
  #   api.gtopo30(lat: 50.01, lng: 10.2)
  def gtopo30(parameters = {})
    query(:gtopo30, parameters)
  end
  QUERY[:gtopo30] = %w[lat lng]

  # Returns the children for a given geonameId. The children are the
  # administrative divisions within an other administrative division. Like the
  # counties (ADM2) in a state (ADM1) or also the countries in a continent.
  #
  # Parameters:
  # geonameId: the geonameId of the parent
  # maxRows: number of rows returned, default is 200
  #
  # Result: returns a list of GeoName records
  #
  # Example:
  #
  #   api.children(geonameId: 3175395, maxRows: 5)
  def children(parameters = {})
    query(:children, parameters)
  end
  QUERY[:children] = %w[geonameId maxRows]

  # Returns all GeoNames higher up in the hierarchy of a place name.
  #
  # Parameters:
  # geonameId: the geonameId for the hierarchy
  #
  # Result: returns a list of GeoName records, ordered by hierarchy level. The
  # top hierarchy (continent) is the first element in the list
  #
  # Example:
  #
  #   api.hierarchy(geonameId: 2657896)
  def hierarchy(parameters = {})
    query(:hierarchy, parameters)
  end
  QUERY[:hierarchy] = %w[geonameId]

  # Returns all neighbours for a place name (currently only available for
  # countries).
  #
  # Parameters:
  # geonameId: the geonameId for the neighbours
  #
  # Result: returns the neighbours of a toponym, currently only implemented for
  # countries
  #
  # Example:
  #
  #   api.neighbours(geonameId: 2658434)
  def neighbours(parameters = {})
    query(:neighbours, parameters)
  end
  QUERY[:neighbours] = %w[geonameId]

  # Returns all siblings of a GeoNames toponym.
  #
  # Parameters:
  # geonameId: the geonameId for the siblings
  #
  # Result: returns a list of GeoNames records that have the same
  # administrative level and the same father
  #
  # Example:
  #
  #   api.siblings(geonameId: 3017382)
  def siblings(parameters = {})
    query(:siblings, parameters)['geonames']
  end
  QUERY[:siblings] = %w[geonameId]

  # Cities and Placenames
  #
  # Returns a list of cities and placenames in the bounding box, ordered by
  # relevancy (capital/population).
  # Placenames close together are filterered out and only the larger name is
  # included in the resulting list.
  #
  # Parameters:
  # north,south,east,west: coordinates of bounding box
  # callback: name of javascript function (optional parameter)
  # lang: language of placenames and wikipedia urls (default = en)
  # maxRows: maximal number of rows returned (default = 10)
  #
  # Example:
  #
  #   api.cities(north: 44.1, south: -9.9, east: -22.4, west: 55.2, lang: 'de')
  def cities(parameters = {})
    query(:cities, parameters)['geonames']
  end
  QUERY[:cities] = %w[north south east west callback lang maxRows]

  # Weather Stations with most recent Weather Observation
  #
  # Returns a list of weather stations with the most recent weather observation.
  #
  # Parameters:
  # north,south,east,west: coordinates of bounding box
  # callback: name of javascript function (optional parameter)
  # maxRows: maximal number of rows returned (default = 10)
  #
  # Example:
  #
  #   api.weather(north: 44.1, south: -9.9, east: -22.4, west: 55.2)
  def weather(parameters = {})
    observations = query(:weather, parameters)['weatherObservations']
    observations.map{|observation| fix_datetime(observation) }
  end
  QUERY[:weather] = %w[north south east west callbck maxRows]

  # Returns the weather station and the most recent weather observation for the
  # ICAO code.
  #
  # Parameters:
  # ICAO: International Civil Aviation Organization (ICAO) code
  # callback: name of javascript function (optional parameter)
  #
  # Example:
  #
  #   api.weather_icao(ICAO: 'LSZH')
  def weather_icao(parameters = {})
    weather = query(:weatherIcao, parameters)['weatherObservation']
    fix_datetime(weather)
  end
  QUERY[:weatherIcao] = %w[ICAO callback]

  # Country information: Capital, Population, Area in square km, Bounding Box
  # of mainland (excluding offshore islands)

  # Parameters : country (default = all countries)
  # lang: ISO-639-1 language code (en,de,fr,it,es,...) (default = english)
  #
  # Example:
  #
  #   api.country_info(lang: 'it', country: 'DE')
  def country_info(parameters = {})
    query(:countryInfo, parameters)["geonames"]
  end
  QUERY[:countryInfo] = %w[country lang]

  # The ISO country code of any given point.
  #
  # Parameters: lat, lng, type, lang, and radius (buffer in km for closest
  # country in coastal areas)
  #
  # With the parameter type=xml this service returns an xml document with iso
  # country code and country name. The optional parameter lang can be used to
  # specify the language the country name should be in.
  # JSON output is produced with type=JSON, which is the default for this
  # library and will be parsed automatically.
  #
  # Example:
  #
  #   api.country_code(lat: 47.03, lng: 10.2)
  def country_code(parameters = {})
    if parameters[:type].to_s =~ /^xml$/i
      query(:countryCode, parameters){|content| return content }
    else
      query(:countryCode, {type: 'JSON'}.merge(parameters))
    end
  end
  QUERY[:countryCode] = %w[lat lng type lang radius]

  # Country Subdivision / reverse geocoding
  # The ISO country code and the administrative subdivision (state, province, ...) of any given point.
  #
  # Parameters: lat, lng, lang, radius
  #
  # If lang is not given, will return the name in the local language.
  # The radius is measured in km and acts as buffer for closest country in
  # costal areas.
  #
  # Example:
  #
  #   api.country_subdivision(lat: 47.03, lng: 10.2)
  #
  #   # With the parameters 'radius' and 'maxRows' you get the closest
  #   # subdivisions ordered by distance:
  #   api.country_subdivision(lat: 47.03, lng: 10.2, maxRows: 10, radius: 40)
  def country_subdivision(parameters = {})
    query(:countrySubdivision, parameters)
  end
  QUERY[:countrySubdivision] = %w[lat lng lang radius]

  # Ocean / reverse geocoding
  # Returns the name of the ocean or sea for the given latitude/longitude.
  #
  # Parameters : lat,lng
  #
  # Example:
  #
  #   api.ocean(lat: 40.78343, lng: -43.96625)
  def ocean(parameters = {})
    query(:ocean, parameters)["ocean"]
  end
  QUERY[:ocean] = %w[lat lng]

  # Neighbourhood / reverse geocoding
  # The neighbourhood for US cities. Data provided by Zillow under cc-by-sa
  # license.
  #
  # Parameters: lat,lng
  #
  # Example:
  #
  #   api.neighbourhood(lat: 40.78343, lng: -73.96625)
  def neighbourhood(parameters = {})
    query(:neighbourhood, parameters)["neighbourhood"]
  end
  QUERY[:neighbourhood] = %w[lat lng]

  # Elevation - SRTM3
  #
  # Shuttle Radar Topography Mission (SRTM) elevation data. SRTM consisted of a
  # specially modified radar system that flew onboard the Space Shuttle
  # Endeavour during an 11-day mission in February of 2000. The dataset covers
  # land areas between 60 degrees north and 56 degrees south.
  # This web service is using SRTM3 data with data points located every
  # 3-arc-second (approximately 90 meters) on a latitude/longitude grid.
  #
  # Parameters : lat,lng;
  # sample area: ca 90m x 90m Result : a single number giving the elevation in
  # meters according to srtm3, ocean areas have been masked as "no data" and
  # have been assigned a value of -32768.
  #
  # Example:
  #
  #   api.srtm3(lat: 50.01, lng: 10.2)
  def srtm3(parameters = {})
    query(:srtm3, parameters)
  end
  QUERY[:srtm3] = %w[lat lng]

  # The timezone at the lat/lng with gmt offset (1. January) and dst offset (1. July)
  #
  # Parameters: lat, lng, radius (buffer in km for closest timezone in coastal areas)
  # needs username
  #
  # If you want to work with the returned time, I recommend the tzinfo library,
  # which can handle the timezoneId. In order to keep dependencies low and the
  # code flexible and fast, we won't do any further handling here.
  #
  # Example:
  #
  #   api.timezone(lat: 47.01, lng: 10.2)
  def timezone(parameters = {})
    query(:timezone, parameters)
  end
  QUERY[:timezone] = %w[lat lng radius]

  # Find nearby toponym
  #
  # Parameters: lat, lng, featureClass, featureCode,
  # radius: radius in km (optional)
  # maxRows: max number of rows (default 10)
  # style: SHORT, MEDIUM, LONG, FULL (default = MEDIUM), verbosity result.
  #
  # Example:
  #
  #   api.find_nearby(lat: 47.3, lng: 9)
  def find_nearby(parameters = {})
    query(:findNearby, parameters)
  end
  QUERY[:findNearby] = %w[
    lat lng featureClass featureCode radius maxRows style
  ]

  # Returns the most detailed information available for the lat/lng query.
  # It is a combination of several services. Example:
  # In the US it returns the address information.
  # In other countries it returns the hierarchy service: http://ws.geonames.org/extendedFindNearby?lat=47.3&lng=9
  # On oceans it returns the ocean name.
  #
  # Parameters : lat,lng
  #
  # Example:
  #
  #   api.extended_find_nearby(lat: 47.3, lng: 9)
  def extended_find_nearby(parameters = {})
    raise(NotImplementedError, "XML queries haven't been implemented.")
    query(:extendedFindNearby, parameters)
  end
  QUERY[:extendedFindNearby] = %w[lat lng]

  # Find nearby populated place / reverse geocoding
  # Returns the closest populated place for the lat/lng query.
  # The unit of the distance element is 'km'.
  #
  # Parameters:
  # lat, lng,
  # radius: radius in km (optional),
  # maxRows: max number of rows (default 10),
  # style: SHORT, MEDIUM, LONG, FULL (default = MEDIUM), verbosity of result
  #
  # Example:
  #
  #   api.find_nearby_place_name(lat: 47.3, lng: 9)
  def find_nearby_place_name(parameters = {})
    query(:findNearbyPlaceName, parameters)["geonames"]
  end
  QUERY[:findNearbyPlaceName] = %w[lat lng radius maxRows style]

  # List of nearby postalcodes and places for the lat/lng query.
  # The result is sorted by distance.
  #
  # This service comes in two flavors. You can either pass the lat/long or a
  # postalcode/placename.
  #
  # Parameters:
  #
  # lat, lng, radius (in km),
  # maxRows (default = 5),
  # style (verbosity : SHORT,MEDIUM,LONG,FULL),
  # country (default = all countries),
  # localCountry (restrict search to local country in border areas)
  #
  # or
  #
  # postalcode, country, radius (in Km), maxRows (default = 5)
  #
  # Example:
  #
  #   api.find_nearby_postal_codes(lat: 47, lng: 9)
  #   api.find_nearby_postal_codes(postalcode: 8775, country: 'CH', radius: 10)
  def find_nearby_postal_codes(parameters = {})
    query(:findNearbyPostalCodes, parameters)["postalCodes"]
  end
  QUERY[:findNearbyPostalCodes] = %w[
    lat lng radius maxRows style country localCountry postalcode country radius
  ]

  # Returns the nearest street segments for the given latitude/longitude, this
  # service is only available for the US.
  #
  # @param [Float] latitude Latitude
  # @param [Float] longitude Longitude
  #
  # @return [Array] An Array containing zero or more street segments.
  #
  # A street segment has following keys:
  # "adminCode1": Identifier of state.
  # "adminCode2": Area code.
  # "adminName1": Name of state.
  # "adminName2": Name of province.
  # "countryCode": Name of country (usually "US")
  # "distance": Distance of street to given coordinates in km.
  # "fraddl": From address left.
  # "fraddr": From address right.
  # "line": A string with lng/lat points, comma separated.
  # "mtfcc": MAF/TIGER Feature class code.
  # "name:" Name of the street.
  # "postalcode": Postal code of the address.
  # "toaddl": To address left.
  # "toaddr": To address right.
  #
  # @example
  #   api.find_nearby_streets(37.451, -122.18)
  def find_nearby_streets(latitude, longitude)
    [*query(:findNearbyStreets, lat: latitude, lng: longitude)['streetSegment']]
  end
  QUERY[:findNearbyStreets] = %w[lat lng]


  # Find nearby street segments on OpenStreetMap for the given
  # latitude/longitude.
  #
  # @param [Float, String] latitude
  # @param [Float, String] longitude
  #
  # @example
  #   api.find_nearby_streets_osm(37.451, -122.18)
  def find_nearby_streets_osm(latitude, longitude)
    query(:findNearbyStreetsOSM, lat: latitude, lng: longitude)
  end
  QUERY[:findNearbyStreetsOSM] = %w[lat lng]

  # Weather Station with most recent weather observation / reverse geocoding
  # needs username
  #
  # Webservice Type : REST
  # Url : ws.geonames.org/findNearByWeatherJSON?
  # Parameters :
  # lat,lng : the service will return the station closest to this given point (reverse geocoding)
  # callback : name of javascript function (optional parameter)
  #
  # Result : returns a weather station with the most recent weather observation
  #
  # Example http://ws.geonames.org/findNearByWeatherJSON?lat=43&lng=-2
  def find_near_by_weather(parameters = {})
    query(:findNearByWeather, parameters)
  end
  QUERY[:findNearByWeather] = %w[lat lng]

  # Find nearby Wikipedia Entries / reverse geocoding
  #
  # This service comes in two flavors. You can either pass the lat/long or a postalcode/placename.
  # Webservice Type : XML,JSON or RSS
  # Url : ws.geonames.org/findNearbyWikipedia?
  # ws.geonames.org/findNearbyWikipediaJSON?
  # ws.geonames.org/findNearbyWikipediaRSS?
  # Parameters :
  # lang : language code (around 240 languages) (default = en)
  # lat,lng, radius (in km), maxRows (default = 5),country (default = all countries)
  # or
  # postalcode,country, radius (in Km), maxRows (default = 5)
  # Result : returns a list of wikipedia entries as xml document
  # Example:
  # http://ws.geonames.org/findNearbyWikipedia?lat=47&lng=9
  # or
  # ws.geonames.org/findNearbyWikipedia?postalcode=8775&country=CH&radius=10
  def find_nearby_wikipedia(parameters = {})
    query(:findNearbyWikipedia, parameters)
  end
  QUERY[:findNearbyWikipedia] = %w[
    lang lat lng maxRows country postalcode country radius
  ]

  # Find nearest Address
  #
  # Finds the nearest street and address for a given lat/lng pair.
  # Url : ws.geonames.org/findNearestAddress?
  # Parameters : lat,lng;
  # Restriction : this webservice is only available for the US.
  # Result : returns the nearest address for the given latitude/longitude, the street number is an 'educated guess' using an interpolation of street number at the end of a street segment.
  # Example http://ws.geonames.org/findNearestAddress?lat=37.451&lng=-122.18
  #
  # This service is also available in JSON format :
  # http://ws.geonames.org/findNearestAddressJSON?lat=37.451&lng=-122.18
  def find_nearest_address(parameters = {})
    query(:findNearestAddress, parameters)
  end
  QUERY[:findNearestAddress] = %w[lat lng]

  #   Find nearest Intersection
  #
  # Finds the nearest street and the next crossing street for a given lat/lng pair.
  # Url : ws.geonames.org/findNearestIntersection?
  # Parameters : lat,lng;
  # Restriction : this webservice is only available for the US.
  # Result : returns the nearest intersection for the given latitude/longitude
  # Example http://ws.geonames.org/findNearestIntersection?lat=37.451&lng=-122.18
  #
  # This service is also available in JSON format :
  # http://ws.geonames.org/findNearestIntersectionJSON?lat=37.451&lng=-122.18
  def find_nearest_intersection(parameters = {})
    query(:findNearestIntersection, parameters)
  end
  QUERY[:findNearestIntersection] = %w[lat lng]

  # Find nearest street and crossing for a given latitude/longitude pair on
  # OpenStreetMap.
  #
  # @param [Float] latitude
  # @param [Float] longitude
  #
  # @example
  #   api.find_nearest_intersection_osm(37.451, -122.18)
  def find_nearest_intersection_osm(parameters = {})
    query(:findNearestIntersectionOSM, parameters)
  end
  QUERY[:findNearestIntersectionOSM] = %w[lat lng]

  # Postal code country info
  #
  # @return [Array] Countries for which postal code geocoding is available.
  #
  # @example
  #   api.postal_code_country_info
  def postal_code_country_info(parameters = {})
    query(:postalCodeCountryInfo, {})['geonames']
  end
  QUERY[:postalCodeCountryInfo] = []

  # Placename lookup with postalcode
  #
  #
  # @param [Hash] parameters
  # @option parameters [String, Fixnum] :postalcode
  # @option parameters [String] :country
  # @option parameters [Fixnum] :maxRows (20)
  # @option parameters [String] :callback
  # @option parameters [String] :charset ('UTF-8')
  #
  # @return [Array] List of places for the given postalcode.
  #
  # @example
  #   api.postal_code_lookup(postalcode: 6600, country: 'AT')
  def postal_code_lookup(parameters = {})
    query(:postalCodeLookup, parameters)
  end
  QUERY[:postalCodeLookup] = %w[postalcode country maxRows, callback charset]

  # Postal Code Search
  # Returns a list of postal codes and places for the placename/postalcode query.
  #
  # For the US the first returned zip code is determined using zip code area
  # shapes, the following zip codes are based on the centroid. For all other
  # supported countries all returned postal codes are based on centroids.
  #
  # Parameter	Value	Description
  # postalcode	string (postalcode or placename required)	postal code
  # postalcode_startsWith	string	the first characters or letters of a postal code
  # placename	string (postalcode or placename required)	all fields : placename,postal code, country, admin name (Important:urlencoded utf8)
  # placename_startsWith	string	the first characters of a place name
  # country	string : country code, ISO-3166 (optional)	Default is all countries.
  # countryBias	string	records from the countryBias are listed first
  # maxRows	integer (optional)	the maximal number of rows in the document returned by the service. Default is 10
  # style	string SHORT,MEDIUM,LONG,FULL (optional)	verbosity of returned xml document, default = MEDIUM
  # operator	string AND,OR (optional)	the operator 'AND' searches for all terms in the placename parameter, the operator 'OR' searches for any term, default = AND
  # charset	string (optional)	default is 'UTF8', defines the encoding used for the document returned by the web service.
  # isReduced	true or false (optional)	default is 'false', when set to 'true' only the UK outer codes are returned. Attention: the default value on the commercial servers is currently set to 'true'. It will be changed later to 'false'.
  #
  # @example
  #   api.postal_code_search(postalcode: 9011, maxRows: 10)
  def postal_code_search(parameters = {})
    query(:postalCodeSearch, parameters)
  end
  QUERY[:postalCodeSearch] = %w[
    postalcode postalcode_starts placename placename_starts country countryBias
    maxRows style operator charset isReduced
  ]

  # Returns the names found for the searchterm as xml, json, or rdf document,
  # the search is using the AND operator.
  #
  # @param [Hash] parameters
  # @option parameters [String] :q
  #   search over all attributes of a place, place name, country name,
  #   continent, admin codes, ...
  # @option parameters [String] :name
  #   place name only
  # @option parameters [String] :name_equals
  #   exact place name
  # @option parameters [String] :name_startsWith
  #   place name starts with given characters
  # @option parameters [Fixnum] :maxRows (100)
  #   maximum number of results, up to 1000
  # @option parameters [Fixnum] :startRow (0)
  #   used for paging results.
  # @option parameters [String, Array] :country
  #   Country code, ISO-3166 (optional). Default is all countries. May have
  #   more than one country as an Array.
  # @option parameters [String] :countryBias
  #   records from this country will be listed first.
  # @option parameters [String] :continentCode
  #   AF,AS,EU,NA,OC,SA,AN (optional) restricts the search to the given
  #   continent.
  # @option parameters [String] :adminCode1
  #   code of administrative subdivision
  # @option parameters [String] :adminCode2
  #   code of administrative subdivision
  # @option parameters [String] :adminCode3
  #   code of administrative subdivision
  # @option parameters [String, Array] :featureClass
  #   one or more feature class codes, explanation at
  #   http://forum.geonames.org/gforum/posts/list/130.page
  # @option parameters [String, Array] :featureCode
  #   one or more feature class codes, explanation at
  #   http://forum.geonames.org/gforum/posts/list/130.page
  # @option parameters [String] :lang ('en')
  #   ISO-636 2-letter language code; en, de, fr, it, es, ...
  #   place names and country names will be returned in the specified language.
  #   Feature classes and codes are only available in English and Bulgarian.
  # @option parameters [String] :type ('json')
  #   format of returned document.
  # @option parameters [String] :style ('MEDIUM')
  #   verbosity of returned document.
  # @option parameters [String] :isNameRequired (false)
  #   At least one of the search term needs to be part of the place name.
  #   Example: A normal seach for Berlin will return all places within the
  #   state of Berlin. If we only want to find places with 'Berlin' in the name
  #   we se the parameter isNameRequired to `true`. The difference to the
  #   :name_equals parameter is that this will allow searches for 'Berlin,
  #   Germany' as only one search term needs to be part of the name.
  # @option parameters [String] :tag
  #   search for toponyms tagged with the given tag.
  # @option parameters [String] :charset ('UTF8')
  #   encoding of returned document, this wrapper only handles UTF8 for now.
  #
  # @example
  #   api.search(q: 'london', maxRows: 10)
  #   api.search(q: 'london', maxRows: 10, type: 'rdf')
  #   api.search(q: 'skiresort')
  #   api.search(q: 'tags:skiresort')
  #   api.search(q: 'tags:skiresort@marc')
  #
  # With the parameter `type: 'rdf'` the search service returns the result in RDF
  # format defined by the GeoNames Semantic Web Ontology.
  #
  #
  # Tags
  # GeoNames is using a simple tagging system. Every user can tag places. In
  # contrast to the feature codes and feature classes which are one-dimensional
  # (a place name can only have one feature code) several tags can be used for
  # each place name. It is an additional categorization mechanism where the
  # simple classification with feature codes is not sufficient.
  #
  # I have tagged a place with the tag 'skiresort'. You can search for tags
  # with the search: `api.search(q: 'skiresort')` If you only want to search
  # for a tag and not for other occurences of the term (in case you tag
  # something with 'spain' for example), then you add the attribute 'tags:' to
  # the search term: `api.search(q: 'tags:skiresort')`
  #
  # And if you want to search for tags of a particular user (or your own) then
  # you append '@username' to the tag. Like this:
  # `api.search(q: 'tags:skiresort@marc')
  def search(parameters = {})
    query(:search, parameters)['geonames']
  end
  QUERY[:search] = %w[
    q name name_equals name_startsWith maxRows startRow country countryBias
    continentCode adminCode1 adminCode2 adminCode3 featureClass featureCode
    lang type style isNameRequired tag operator charset
  ]

  # Wikipedia articles within a bounding box
  #
  # @param [Hash] parameters
  # @option parameters [Float] :south Southern latitude
  # @option parameters [Float] :north Northern latitude
  # @option parameters [Float] :east Eastern longitude
  # @option parameters [Float] :west Western longitude
  # @option parameters [String] :lang ('en') language
  # @option parameters [Fixnum] :maxRows ('10') maximum number of results
  #
  # @return [Array] The Wikipedia entries found.
  #
  # @example
  #   api.wikipedia_bounding_box(north: 44.1, south: -9.9, east: -22.4, west: 55.2)
  def wikipedia_bounding_box(parameters = {})
    [*query(:wikipediaBoundingBox, parameters)['geonames']]
  end
  QUERY[:wikipediaBoundingBox] = %w[south north east west lang maxRows]

  # Wikipedia Fulltext Search
  #
  # @param [Hash] parameters
  # @option parameters [String] :q
  #   place name
  # @option parameters [String] :title (false)
  #   search in the wikipedia title (optional, true/false)
  # @option parameters [String] :lang ('en')
  #   language
  # @option parameters [Fixnum] :maxRows (10)
  #   maximum number of results
  #
  # @return [Array] The Wikipedia entries found.
  #
  # @example
  #   api.wikipedia_search(q: 'London', maxRows: 10, lang: 'en', title: true)
  #   api.wikipedia_search(q: '秋葉原')
  def wikipedia_search(parameters = {})
    params = parameters.dup
    params[:title] = '' if params[:title] # weird?
    [*query(:wikipediaSearch, params)['geonames']]
  end
  QUERY[:wikipediaSearch] = %w[q title lang maxRows]
end

api = GeoNames.new
ocean = api.ocean(lat: 0, lng: 0)
puts "ocean: #{ocean}"
# oceanName = ocean(:name)
# puts oceanName
testLoc = "lat: 33.81222, lng: -118.38361"
testLat = 33.81222
testLng = -118.38361

#  neighborhood fails for this
testLat =   33.836603
testLng = -118.377645
# but works for this and doesn't work until get to 2 significant digits her 
testLat =   33.83
testLng = -118.37


country = api.country_code(lat: testLat, lng: testLng)
puts "country: #{country}"
puts "\ncountry['countryName']: #{country['countryName']}"

extFind = api.find_nearby(lat: testLat, lng: testLng)
# leng = extFind.length
# leng2 = leng - 16
# extFind2 = extFind[14,leng2]
extFind2 = extFind['geonames']
puts "\n808. find_nearby: #{extFind}"
# puts "807. #{leng} #{leng2} #{extFind2}. Looks good, but now a string and not an array"
# puts "\n804. find_nearby: #{extFind}"
puts "\n810. find_nearby: #{extFind2}. Yes but it's not an array. Could parse it, but it's a pain. "
# puts "\n810. find_nearby: #{extFind2['name']}"
# puts "Note that find_nearby is a hash inside an array or the opposite or what?"
puts "\nfind_nearby['countryName']: #{extFind['countryName']}"
# puts "\nfind_nearby[1]['countryName']: #{extFind[1]['countryName']}"
puts "\nfind_nearby['name']: #{extFind['name']}. find_nearby['toponymName']: #{extFind['toponymName'] }"

extFind = {"countryId"=>"6252001", "adminCode1"=>"CA", "countryName"=>"United States", "fclName"=>"spot, building, farm", "countryCode"=>"US", "lng"=>"-118.37306", "fcodeName"=>"military installation", "distance"=>"0.28285", "toponymName"=>"Nike Site LA-57C (historical)", "fcl"=>"S", "name"=>"Nike Site LA-57C (historical)", "fcode"=>"INSM", "geonameId"=>7266707, "lat"=>"33.83", "adminName1"=>"California", "population"=>0}
puts "\n813. find_nearby['name']: #{extFind['name']}. find_nearby['toponymName']: #{extFind['toponymName'] }"



place = api.find_nearby_place_name(lat: testLat, lng: testLng)
puts "\nplace: #{place}"
puts "\nplace[0]: #{place[0]}"
place = place[0]
place['countryName']
puts "\n find_nearby_place_name['countryName']: #{place['countryName']}"

puts "\nplace[0]['name']: #{place['name']}\n place[0]['toponymName']: #{place['toponymName']}\nadminName1:  #{place['adminName1']}"

street = api.find_nearby_postal_codes(lat: testLat, lng: testLng)
puts "\n819. find_nearby_postal_codes: #{street}"
puts "\n820. find_nearby_postal_codes[0]['placeName']: #{street[0]['placeName']}\n"

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
puts "835. testLat: #{testLat} testLng: #{testLng}"
puts "836. api.neighbourhood(lat: testLat, lng: testLng) #{api.neighbourhood(lat: testLat, lng: testLng)}"
neigh = api.neighbourhood(lat: testLat, lng: testLng)
puts neigh
puts = "\n839: neigh: #{neigh}"
puts "name, city, adminName2, adminCode1: #{neigh['name']}, #{neigh['city']}, #{neigh['adminName2']}, #{neigh['adminCode1']}" 


timeZ = api.timezone(lat: testLat, lng: testLng)
# => timeZ: {"time"=>"2013-11-11 09:19", "countryName"=>"United States", "sunset"=>"2013-11-11 16:52", "rawOffset"=>-8, "dstOffset"=>-7, "countryCode"=>"US", "gmtOffset"=>-8, "lng"=>-118.38361, "sunrise"=>"2013-11-11 06:21", "timezoneId"=>"America/Los_Angeles", "lat"=>33.81222}
puts "timeZ: #{timeZ}. {timeZ['gmtOffset']}"
puts "\n++++++++++++++++++++++\n"

wpd = api.find_nearby_wikipedia(testLat testLng) # doesn't work and I can't figure out what does
puts = "850. find_nearby_wikipedia: #{wpd}"