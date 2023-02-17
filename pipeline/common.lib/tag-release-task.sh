#!/bin/bash
cd applications/tradingnetworks
MAJOR=`sed -n 's/^MAJOR=\(.*\)/\1/p' < version.txt`
MINOR=`sed -n 's/^MINOR=\(.*\)/\1/p' < version.txt`
PATCH=`sed -n 's/^PATCH=\(.*\)/\1/p' < version.txt`
VERSION=v${MAJOR}.${MINOR}.${PATCH}
# Display the tags
git tag

# Create the tag
git tag -a ${VERSION} -m "Tag for release ${VERSION}"

# Display the specific tag
git show ${VERSION}

# Push to the origin
git push origin ${VERSION}