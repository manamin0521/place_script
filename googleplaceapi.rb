require 'net/https'
require 'uri'
require 'json'

# API_KEY = 'AIzaSyDEhtQbIdDR_5KQjMBgIPSoEb2IELXYTG0'
API_KEY = 'AIzaSyDVUuLJdMwQA_WPJRAJM2ngyKrUK4r_ROw'
# API_KEY = 'AIzaSyDRK0rZvGzZ2lvu-jW3A3TAExcuEnE5wiU'
# API_KEY = 'AIzaSyB379FMFKJO5sx58uIVkuAfl6SE9ie08gA'

lat = '1.5187515'
lng = '103.569053'
rad = '50000'

# types = 'train_station'
types = 'university'
# types = 'doctor'
# types = 'school'
# types = 'shopping_mall'
# types = 'hospital'
# types = 'bus_station'
# types = 'subway_station'


language = 'en'

uri = URI.parse "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=#{lat},#{lng}&radius=#{rad}&types=#{types}&language=en&key=#{API_KEY}"

request = Net::HTTP::Get.new(uri.request_uri)
response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

body = JSON.parse response.body
results = body['results']

results.each do |result|
  place_id = result['place_id']

  uri2 = URI.parse "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&language=en&key=#{API_KEY}"

  request = Net::HTTP::Get.new(uri2.request_uri)
  response = Net::HTTP.start(uri2.host, uri2.port, use_ssl: uri2.scheme == 'https') do |http|
    http.request(request)
  end

  detail = JSON.parse response.body
  place_detail = detail['result']
  location = place_detail['geometry']['location']
  address = place_detail['address_components']
  check_items = ["street_number", "route", "locality", "administrative_area_level_2", "administrative_area_level_1", "country"]
  place = {}

  address.each do |element|
    result = element["types"] & check_items
    next if result.empty?
    place[result[0]] = element["long_name"]
  end

  answer = {
    name:place_detail['name'],
    lat: location['lat'],
    lng:location['lng'],
    address:place_detail['formatted_address'],
    street_number:place['street_number'],
    route:place['route'],
    locality:place['locality'],
    area_level_1:place['administrative_area_level_1'],
    country:place['country'],
    types: place_detail['types']
  }

    list = ['establishment', 'point_of_interest']
    place_detail['types'].delete_if do |str|
      list.include?(str)
    end

  if place['country'] == "Malaysia" then
    File.open('./place.json', 'a') do |file|
        file.puts JSON.pretty_generate(answer)
    end
  end
end