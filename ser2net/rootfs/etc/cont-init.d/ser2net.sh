#!/usr/bin/with-contenv bashio

data_port=12345
admin_port=12346

serial_device=$(bashio::config serial_device)
baud=$(bashio::config baud_rate 115200)
parity=$(bashio::config parity n)
data_bits=$(bashio::config data_bits 8)
stop_bits=$(bashio::config stop_bits 1)
protocol=$(bashio::config protocol tcp)
max_connections=$(bashio::config max_connections 4)

# Construct serial config string (e.g., 115200n81)
serial_config="${baud}${parity}${data_bits}${stop_bits}"

# Construct TCP accepter line (e.g., tcp,12345)
accepter_line="${protocol},${data_port}"

cat >> /etc/ser2net/ser2net.yaml << EOF

connection: &serport
  accepter: $accepter_line
  timeout: 0 # don't timeout on no activity
  enable: on
  connector: serialdev, $serial_device,$serial_config,local
  options:
    max-connections: $max_connections

EOF
# TODO add a rotator that prints an error saying the port is in use? and then echo?

if bashio::config.true "enable_admin_interface"; then
cat >> /etc/ser2net/ser2net.yaml << EOF

admin:
  accepter: tcp,$admin_port

EOF

# Optional: log startup info for debugging
echo "Starting ser2net with:"
echo "  serial device: $serial_device"
echo "  serial config: $serial_config"
echo "  protocol: $protocol"
echo "  TCP port: $data_port"
echo "  max connections: $max_connections"

fi