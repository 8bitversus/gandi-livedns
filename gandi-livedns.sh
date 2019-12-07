#!/usr/bin/env bash

# Reference:
#  - https://doc.livedns.gandi.net/

# Gandi livedns API KEY
APIKEY=""
# Static domain
DOMAIN="example.com"
# Dynamic subdomain
SUBDOMAIN=$(hostname -s)

function validate_ip {
    local IP_ADDR="${1}"
    #Variable to test that if the octet is between 1 and 254
    local IP_TEST='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
    if [[ ${IP_ADDR} =~ ^$IP_TEST\.$IP_TEST\.$IP_TEST\.$IP_TEST$ ]]; then
        echo "FOUND: ${IP_ADDR}"
    else
        echo "ERROR! ${IP_ADDR} is not valid."
        exit 1
    fi
}

function usage {
  echo
  echo "Usage"
  echo "  ${0} [--apikey API_TOKEN] [--domain example.com] [--hostname $(hostname -s)] [--help]"
  echo
  echo "You can also pass optional parameters"
  echo "  --apikey    : Gandi.net API token."
  echo "  --domain    : Domain hosted at Gandi.net."
  echo "  --subdomain : Subdomain you want to associate with your IP address."
  echo "  --help      : This help."
  echo
  exit 1
}

# Check for optional parameters
while [ $# -gt 0 ]; do
  case "${1}" in
    -apikey|--apikey)
      APIKEY="$2"
      shift
      shift;;
    -domain|--domain)
      DOMAIN="$2"
      shift
      shift;;
    -subdomain|--subdomain)
      SUBDOMAIN="$2"
      shift
      shift;;
    -h|--h|-help|--help)
      usage;;
    *)
      echo "ERROR! \"${1}\" is not a supported parameter."
      usage;;
  esac
done

if [ -z "${APIKEY}" ]; then
  echo "ERROR! You need to provide a Gandi.net API token."
  exit 1
fi

if [ -z "${DOMAIN}" ]; then
  echo "ERROR! No domain provided."
  exit 1
fi

if [ -z "${SUBDOMAIN}" ]; then
  echo "ERROR! No subdomain provided."
  exit 1
fi

# Get current Internet facing IP address.
IP=$(curl -s https://api.ipify.org/ | head -n 1 | sed 's/ //g')
validate_ip "${IP}"

# Get the current zone for the provided domain
CURRENT_ZONE_HREF=$(curl -s -H "X-Api-Key: ${APIKEY}" https://dns.api.gandi.net/api/v5/domains/${DOMAIN} | jq -r '.zone_records_href')
if [ "${CURRENT_ZONE_HREF}" == "null" ]; then
  echo "ERROR! Could not find ${DOMAIN} zone using the provided Gandi.net API token."
  exit 1
fi

echo -e "Assigning ${SUBDOMAIN}.${DOMAIN} to ${IP}\n"

# Update the A record of the Dynamic Subdomain by PUTing to the current zone
curl -D- -X PUT -H "Content-Type: application/json" \
     -H "X-Api-Key: ${APIKEY}" \
     -d "{\"rrset_name\": \"${SUBDOMAIN}\",
            \"rrset_type\": \"A\",
            \"rrset_ttl\": 1800,
            \"rrset_values\": [\"${IP}\"]}" \
     ${CURRENT_ZONE_HREF}/${SUBDOMAIN}/A