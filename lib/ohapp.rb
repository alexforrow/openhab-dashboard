require 'net/https'
require 'json'

#
# Object grants REST-ful access to a ST SmartApp endpoint. This
# object also handles authorization with SmartThings.
# 
class OHApp
  attr_reader :openhab_items_uri

  attr_reader :temperature, :currentConditions, :humidity, :pressure, :precipitation, :windSpeed, :temperatureLow, 
    :temperatureHigh, :weatherIcon, :weatherCode, :tomorrowTemperatureLow, :tomorrowTemperatureHigh, :tomorrowWeatherIcon, :tomorrowPrecipitation,
    :windSpeed, :windDirection, :windGust, :weatherObsTime, :sunrise, :sunset

  def initialize(openhab_uri)
    @openhab_items_uri = "#{openhab_uri}/rest/items"

    #@endpoint = endpoint
    @temperature=0.0
    @currentConditions=""
    @humidity=0.0
    @pressure=0.0
    @precipitation=0
    @windSpeed=0
    @temperatureLow=0.0
    @temperatureHigh=0.0
    @weatherIcon=""
    @weatherCode=""
    @tomorrowTemperatureLow=0.0
    @tomorrowTemperatureHigh=0.0
    @tomorrowPrecipitation=0
    @tomorrowWeatherIcon=""
    @weatherObsTime=nil
    @windSpeed=0
    @windGust=0
    @windDirection=""
    @sunrise=nil
    @sunset=nil
  end

  # openHAB REST call
  def getState(itemID, data)
    itemRequest(itemID)
  end

  def sendCommand(itemID, newState, data)
    itemRequest(itemID, newState)
  end

  # make request to OpenHAB. Specifying command will send a POST
  # I believe this will work on OpenHAB2, but not tested
  def itemRequest(itemID, command = nil)
    uri = URI("#{@openhab_items_uri}/#{itemID}")
    puts "[OpenHAB] Sending request for item '#{itemID}' with command '#{command}'"
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = if command
                  Net::HTTP::Post.new uri
                else
                  Net::HTTP::Get.new uri
                end
      request.basic_auth uri.user, uri.password if uri.user
      request['Accept'] = 'application/json'

      if command
        request.body = command
        request['Content-Type'] = 'text/plain'
      end

      response = http.request request # Net::HTTPResponse object

      raise "Unexpected HTTP code from OpenHAB: #{response.code}" unless ['200', '201'].include? response.code
      puts response.body
      response.body
    end
  end

  def refreshWeather()
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = OPENHAB_SSL
    http.basic_auth(OPENHAB_USER, OPENHAB_PASSWORD)
    response = http.request(Net::HTTP::Get.new("/rest/items/Weather?type=json"))
    #puts response.body()
    data = JSON.parse(response.body())
    #puts data
    data["members"].each do |member|
      #p member["name"] + ": " + member["state"]
      value = member["state"]

      case member["name"]
        when "Weather_Temperature"
          @temperature=value.to_f.round 
        when "Weather_Conditions"
          @currentConditions = value
        when "Weather_Code"
          @weatherCode = value           
          @weatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Temp_Max_0"
          @temperatureHigh = value.to_f.round               
        when "Weather_Temp_Min_0"
          @temperatureLow = value.to_f.round    
        when "Weather_Humidity"
          @humidity = value.to_f.round 
        when "Weather_Pressure"
          @pressure = value.to_f.round 
        when "Weather_Temp_Max_1"
          @tomorrowTemperatureHigh = value.to_f.round    
        when "Weather_Temp_Min_1"
          @tomorrowTemperatureLow = value.to_f.round    
        when "Sunrise_Time"
          @sunrise = value
        when "Sunset_Time"
          @sunset = value
        when "Weather_ObsTime"
          @weatherObsTime = value
        when "Weather_Code_1"
          @tomorrowWeatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Precipitation"
          @precipitation = value[0..-4]
        when "Weather_Precipitation_1"
          @tomorrowPrecipitation=value.to_f.round           
        when "Weather_Wind_Speed"
          @windSpeed=value.to_f.round 
        when "Weather_Wind_Direction"
          @windDirection=value
        when "Weather_Wind_Gust"
          @windGust=value.to_f.round 
      end
    end

    puts self.to_yaml
    data
  end

  def getWeather()


  end


    
  # SCHEDULER.every '5m', :first_in => 0 do |job|
  #   http = Net::HTTP.new("api.forecast.io", 443)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  #   response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  #   forecast = JSON.parse(response.body)  
  #   forecast_current_temp = forecast["currently"]["temperature"].round
  #   forecast_hour_summary = forecast["minutely"]["summary"]
  #   send_event('forecast', { temperature: "#{forecast_current_temp}&deg;", hour: "#{forecast_hour_summary}"})
  # end

#  private :refreshToken, :getEndpoint, :retrieveToken, :storeToken

end
