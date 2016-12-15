require 'mqtt'

# Set your MQTT server
MQTT_SERVER = 'mqtt://localhost'

# Start a new thread for the MQTT client, retry connection on exception
Thread.new {
  while true do
    begin
      MQTT::Client.connect(MQTT_SERVER) do |client|
        puts 'Connected to MQTT'
        client.subscribe('openhab/dashboard/+')

        client.get do |topic,message|
          # openhab/dashboard/Light_Garden => '1 <microtime>'
          item = topic.split('/')[2]
          value = message.split(' ').first
          time = message.split(' ').last

          puts "Sending MQTT update for '#{item}' to value '#{value}' (updated #{time})"
          send_event(item, { state: value })
        end
      end
    rescue Exception =>e
      puts "MQTT exception: " + e.to_s
    end
    sleep 10
  end
}
