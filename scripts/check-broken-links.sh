#!/bin/bash
#
# Check for broken links.
#
set -e

docker run --rm --link alleau:site dcycle/broken-link-checker:2 http://site
