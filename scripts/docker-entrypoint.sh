#!/bin/bash

# Referencing the official docker-entrypoint https://github.com/docker-library/cassandra/blob/master/4.0/docker-entrypoint.sh

set -e

_ip_address() {
        # scrape the first non-localhost IP address of the container
        # in Swarm Mode, we often get two IPs -- the container IP, and the (shared) VIP, and the container IP should always be first
        ip address | awk '
        $1 != "inet" { next } # only lines with ip addresses
        $NF == "lo" { next } # skip loopback devices
        $2 ~ /^127[.]/ { next } # skip loopback addresses
        $2 ~ /^169[.]254[.]/ { next } # skip link-local addresses
        {
                        gsub(/\/.+$/, "", $2)
                        print $2
                        exit
                }
        '
}

_sed-in-place() {
        local filename="$1"; shift
        local tempFile
        tempFile="$(mktemp)"
        sed "$@" "$filename" > "$tempFile"
        cat "$tempFile" > "$filename"
        rm "$tempFile"
}

if [ -f "$CASSANDRA_CONF/cassandra-ro.yaml" ]; then
    cp "$CASSANDRA_CONF"/cassandra-ro.yaml "$CASSANDRA_CONF"/cassandra.yaml
fi

if [[ -z "${RCP_ADDRESS}" ]]; then
    RCP_ADDRESS="$(_ip_address)"
fi

_sed-in-place "$CASSANDRA_CONF/cassandra.yaml" \
  -r 's/(rpc_address:).*/\1 '"$RCP_ADDRESS"' /'

_sed-in-place "$CASSANDRA_CONF/cassandra.yaml" \
-r 's/enable_drop_compact_storage: false/enable_drop_compact_storage: true/'

{
for ((;;))
    do
        while ! cqlsh -u cassandra -p cassandra -e 'describe cluster' > /dev/null 2>&1 ; do
            sleep 3
        done
        if [ -n "$CASSANDRA_USERNAME" ] && [ -n "$CASSANDRA_PASSWORD" ]; then
            cqlsh -u cassandra -p cassandra -e "create user if not exists $CASSANDRA_USERNAME with password '$CASSANDRA_PASSWORD' superuser"
            cqlsh -u "$CASSANDRA_USERNAME" -p "$CASSANDRA_PASSWORD" -e "drop user if exists cassandra"
        fi
        break
    done
} &

export JVM_OPTS

exec "$@"
