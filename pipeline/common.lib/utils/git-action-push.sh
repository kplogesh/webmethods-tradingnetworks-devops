#!/bin/bash
git config user.name "Jenkins"
git config user.email "Jenkins@jenkins.com"
git add ExportedData.bin
git commit -m "committing exported tn data"
git push origin HEAD:$1