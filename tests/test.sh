#!/bin/bash
set -e
FQDN="$1"
Ipv4="$2"


# Test HTTP 200
curl --cacert ../terraform/modules/gateway/certificates/root.cer --resolve "$FQDN:443:$Ipv4" -H "Host: $FQDN"  -sf https://$FQDN/api/quote -verbose

