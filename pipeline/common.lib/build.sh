#!/bin/bash
# Navigate to the desired location
cd applications/

# Create the image using the docker file defined
docker build -t wm.msr.tn.app:r.$1 -f tradingnetworks/Dockerfile .