#! /bin/bash

ZONEID=""
RECORDID=""
TOKEN=""
DOMAIN=""
IPV6=$(curl -m 10 -s ipv6.ip.sb)
[[ -z $IPV6 ]] && exit 1

RECORD="{\"type\": \"AAAA\", \"name\": \"$DOMAIN\", \"content\": \"$IPV6\", \"ttl\": 1, \"proxied\": false}"
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID/" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type:application/json" \
    -d "$RECORD"
