require 'json'

app = OHApp.new(YAML.load(File.open("settings.yml"))['openhab']['uri'])

get '/openhab/dispatch' do
  puts "Ignoring widget-triggered request for data for #{params['deviceId']}"
  #app.getState(params['deviceId'], params)
end

post '/openhab/dispatch' do
  app.sendCommand(params['deviceId'], params["command"],params)
end

# Weather update
#SCHEDULER.every '5m', :first_in => 0 do |job|
#app.refreshWeather()
# 
## Emit the event
#if app.currentConditions.length >0 
#	send_event('weather', {
#	   now_temp: app.temperature,
#	   humidity: app.humidity,
#	   temp_low: app.temperatureLow,
#	   temp_high: app.temperatureHigh,
#	   precip: app.precipitation,
#	   humidity: app.humidity,
#	   icon: app.weatherIcon,
#	   tomorrow_temp_low: app.tomorrowTemperatureLow,
#	   tomorrow_temp_high: app.tomorrowTemperatureHigh,
#	   tomorrow_icon: app.tomorrowWeatherIcon,
#	   tomorrow_precip: app.tomorrowPrecipitation,
#	   wind_speed: app.windSpeed,
#	   wind_speed_gust: app.windGust,
#	   wind_dir: app.windDirection})
#  end
#end