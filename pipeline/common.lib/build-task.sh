#!/bin/bash
# Navigate to the desired location
cd applications/
VERSION=$1
# Create the image using the docker file defined
docker build -t wm.msr.tn.app:${VERSION} -f tradingnetworks/Dockerfile .