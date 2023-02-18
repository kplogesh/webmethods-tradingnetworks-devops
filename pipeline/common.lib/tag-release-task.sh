#!/bin/bash
cd applications/tradingnetworks
VERSION=$1
# Display the tags
git tag

# Create the tag
git tag -f -a ${VERSION} -m "Tag for release ${VERSION}"

# Display the specific tag
git show ${VERSION}

# Push to the origin
git push -f origin ${VERSION}