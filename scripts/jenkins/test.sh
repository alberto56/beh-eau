#!/bin/bash
#
# Run tests on a Docker host. Requirements:
# * https://github.com/dcycle/docker-digitalocean-php.
# * the alleau droplet should be deleted in "Post-build Actions".
# * DOCKERHOSTUSER, DOCKERHOSTUSER set using Jenkins's
#   /credentials/store/system/domain/_/ section.
#
set -e

if [ -z "$DOCKERHOSTUSER" ] || [ -z "$DOCKERHOST" ]; then
  >&2 echo "Please configure DOCKERHOSTUSER and DOCKERHOST using"
  >&2 echo "Jenkins secrets (credentials) and export."
  exit 1
fi

# Create a droplet
DROPLET_NAME=alleau
IP1=$(ssh "$DOCKERHOSTUSER"@"$DOCKERHOST" \
  "./digitalocean/scripts/new-droplet.sh $DROPLET_NAME")
# https://github.com/dcycle/docker-digitalocean-php#public-vs-private-ip-addresses
IP2=$(ssh "$DOCKERHOSTUSER"@"$DOCKERHOST" "./digitalocean/scripts/list-droplets.sh" |grep "$IP1" --after-context=10|tail -1|cut -b 44-)
echo "Now determining which of the IPs $IP1 or $IP2 is the public IP"
if [[ $IP1 == 10.* ]]; then
  IP="$IP2";
else
  IP="$IP1";
fi
echo "Created Droplet at $IP"
sleep 90

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  root@"$IP" "rm -rf beh-site && mkdir -p beh-site"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r * root@"$IP":beh-site
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  root@"$IP" \
  "cd beh-site && ./scripts/ci.sh"
