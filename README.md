# gandi-livedns

Dynamically update Gandi.net hosted DNS subdomains.

# Requirements

gandi-livedns is a shell script that uses the following awesome software.

  - `bash`
  - `coreutils`
  - `curl`
  - `jq`
  - `hostname`
  - `sed`

## Install

### Ubuntu 18.04 or newer

    sudo apt -y install curl jq

# Documentation

```
Usage
  ./gandi-livedns.sh [--apikey API_TOKEN] [--domain example.com] [--hostname designare] [--help]

You can also pass optional parameters
  --apikey    : Gandi.net API token.
  --domain    : Domain hosted at Gandi.net.
  --subdomain : Subdomain you want to associate with your IP address.
  --help      : This help.
```