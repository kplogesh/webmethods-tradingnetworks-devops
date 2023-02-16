# Push to Repository
# use base64 to encode binary data and -w0 all in one-line stream
content=$(base64 --wrap=0 /applications/tradingnetworks/sourcecode/tn-assets/ExportedData-$1.zip)
message="Commit from Jenkins task"
committer_name="Jenkins"
committer_email="jenkins@jenkins.com"
auth="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"
branch=$2
# Form the JSON String payload for Github push
JSON_STRING="{
\"message\":\"${message}\",
\"committer\":{\"name\":\"${committer_name}\",\"email\":\"${committer_email}\"},
\"content\":\"${content}\",
\"branch\":\"${branch}\"
}"
# Commit the exported content in Github
echo ${JSON_STRING} |
curl \
    -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Authorization: Bearer $auth" \
    --url https://api.github.com/repos/kplogesh/webmethods-tradingnetworks-devops/contents/applications/tradingnetworks/sourcecode/tn-assets/ExportedData-$1.zip \
    --data-binary @-