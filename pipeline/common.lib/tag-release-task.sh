#!/bin/bash

# Display the tags
git tag

# Create the tag
git tag -a v0.1.$1 -m "Tag for release v0.1.$1"

# Display the specific tag
git show v0.1.$1

# Push to the origin
git push origin v0.1.$1