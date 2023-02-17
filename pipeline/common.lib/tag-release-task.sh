#!/bin/bash
cd applications/tradingnetworks
MAJOR = `sed -n 's/^MAJOR=\(.*\)/\1/p' < version.txt`
MINOR = `sed -n 's/^MINOR=\(.*\)/\1/p' < version.txt`
PATCH = `sed -n 's/^PATCH=\(.*\)/\1/p' < version.txt`
# Display the tags
git tag

# Create the tag
git tag -a v${MAJOR}.${MINOR}.${PATCH} -m "Tag for release v${MAJOR}.${MINOR}.${PATCH}"

# Display the specific tag
git show v${MAJOR}.${MINOR}.${PATCH}

# Push to the origin
git push origin v${MAJOR}.${MINOR}.${PATCH}