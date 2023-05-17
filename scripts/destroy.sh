#!/bin/bash
set -e

docker kill alleau 2>/dev/null || true
docker rm alleau 2>/dev/null || true

# If we try to remove ./docs/_site, ./docs/.jekyll* here, we might
# get permission denied, for example on CircleCI. Removing these items within
# the same container used to create them makes it more likely for this to
# work.
docker pull jekyll/minimal:4
docker run --rm \
  --volume="$PWD/docs:/srv/jekyll" \
  jekyll/minimal:4 \
  /bin/bash -c 'rm -rf /srv/jekyll/_site .jekyll*'

echo 'Environment destroyed.'
