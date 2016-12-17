require 'mqtt'

# Set your MQTT server
MQTT_SERVER = YAML.load(File.open("settings.yml"))['mqtt']['uri']
MQTT_RETRY = 10

# Start a new thread for the MQTT client, retry connection on exception
Thread.new {
  while true do
    begin
      MQTT::Client.connect(MQTT_SERVER) do |client|
        puts '[MQTT] Connected'
        client.subscribe('openhab/dashboard/+')

        client.get do |topic,message|
          # openhab/dashboard/Light_Garden => '1 <microtime>'
          item = topic.split('/')[2]
          value = message.split(' ').first
          time = message.split(' ').last

          puts "[MQTT] Received update for '#{item}' to value '#{value}' (updated #{time})"
          send_event(item, { state: value })
        end
      end
    rescue Exception =>e
      puts "[MQTT] Exception: " + e.to_s + ". Waiting #{MQTT_RETRY}s before retry"
    end
    sleep MQTT_RETRY
  end
}
