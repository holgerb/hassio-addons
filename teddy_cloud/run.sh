#!/usr/bin/with-contenv bashio
set -o errexit
set -o pipefail
set -o nounset

CONFIG_PATH=/data/options.json

bashio::log.info 'Preparing config directories... '
mkdir -p /config/config
mkdir -p /config/certs/server
mkdir -p /config/certs/client
mkdir -p /config/data/

bashio::log.info 'Soft link config directories... '
cd /teddycloud
rm -rf config
rm -rf certs
rm -rf data
ln -s /config/config config
ln -s /config/certs certs
ln -s /config/data data

if bashio::config.is_empty 'mqtt' && bashio::var.has_value "$(bashio::services 'mqtt')"; then
    if bashio::var.true "$(bashio::services 'mqtt' 'ssl')"; then
        export MQTT_SERVER="mqtts://$(bashio::services 'mqtt' 'host'):$(bashio::services 'mqtt' 'port')"
    else
        export MQTT_SERVER="mqtt://$(bashio::services 'mqtt' 'host'):$(bashio::services 'mqtt' 'port')"
    fi

    export MQTT_USER="$(bashio::services 'mqtt' 'username')"
    export MQTT_PASSWORD="$(bashio::services 'mqtt' 'password')"

    bashio::log.info "Using MQTT config from provided service: "
    bashio::log.info "  host: ${MQTT_SERVER}"
    bashio::log.info "  username: ${MQTT_USER}"
    bashio::log.info "  password: <hidden>"

    bashio::log.info ""
    bashio::log.info ""
    bashio::log.info "Configuring MQTT for teddycloud ... "
    python3 -m crudini --set /config/config/config.ini "" mqtt.enabled true
    python3 -m crudini --set /config/config/config.ini "" mqtt.port $(bashio::services 'mqtt' 'port')
    python3 -m crudini --set /config/config/config.ini "" mqtt.hostname $(bashio::services 'mqtt' 'host')
    python3 -m crudini --set /config/config/config.ini "" mqtt.username $(bashio::services 'mqtt' 'username')
    python3 -m crudini --set /config/config/config.ini "" mqtt.password $(bashio::services 'mqtt' 'password')
    bashio::log.info "Watch the logs, if everything looks fine, you should have a new device in your MQTT integration. "
fi

bashio::log.info 'Starting teddy cloud ... '
teddycloud