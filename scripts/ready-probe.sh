#!/bin/bash
​
# Reference: https://github.com/kubernetes/examples/blob/master/cassandra/image/files/ready-probe.sh
# The parameter '-h ::FFFF:127.0.0.1' is to resolve the following error about IPv6 address with OpenJDK 11:
#  - nodetool: Failed to connect to '127.0.0.1:7199'
#  - URISyntaxException: 'Malformed IPv6 address at index 7: rmi://[127.0.0.1]:7199'.
if [[ $(nodetool -h ::FFFF:127.0.0.1 status | grep 127.0.0.1) == *"UN"* ]]; then
  exit 0
else
  exit 1
fi
