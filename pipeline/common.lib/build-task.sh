#!/bin/bash
# Navigate to the desired location
cd applications/

MAJOR=`sed -n 's/^MAJOR=\(.*\)/\1/p' < tradingnetworks/version.txt`
MINOR=`sed -n 's/^MINOR=\(.*\)/\1/p' < tradingnetworks/version.txt`
PATCH=`sed -n 's/^PATCH=\(.*\)/\1/p' < tradingnetworks/version.txt`
VERSION=v${MAJOR}.${MINOR}.${PATCH}
# Create the image using the docker file defined
docker build -t wm.msr.tn.app:${VERSION} -f tradingnetworks/Dockerfile .