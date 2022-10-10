#!/usr/bin/env bash
#
# gh-dl-release! It works!
#
# This script downloads an asset from latest or specific Github release of a
# private repo. Feel free to extract more of the variables into command line
# parameters.
#
# PREREQUISITES
#
# curl, wget, jq
#
# USAGE
#
# Set all the variables inside the script, make sure you chmod +x it, then
# to download specific version to my_app.tar.gz:
#
#     gh-dl-release 2.1.1 my_app.tar.gz
#
# to download latest version:
#
#     gh-dl-release latest latest.tar.gz
#
# If your version/tag doesn't match, the script will exit with error.

#TOKEN="<github_access_token>"
#REPO="<user_or_org>/<repo_name>"
#FILE="<name_of_asset_file>"      # the name of your release asset file, e.g. build.tar.gz
#VERSION=$1                       # tag name or the word "latest"
GITHUB="https://api.github.com"

alias errcho='>&2 echo'

function gh_curl() {
  curl -H "Authorization: token $TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       $@
}

assetParser=". | map(select(.tag_name == \"$VERSION\"))[0].assets"
assetsJson=$(gh_curl -s $GITHUB/repos/$REPOSITORY/releases?per_page=100 | jq "$assetParser")
assetPatternParser="map(select(.name|test(\"$PATTERN\")))"
filteredAssets=$(jq -c "$assetPatternParser" <<< "$assetsJson")

if [ -z "$filteredAssets" ]; then
  assetCount=0
else
  assetCount=$(jq -c "[. | length] | max" <<< "$filteredAssets")

  if [ -z "$assetCount" ]; then
    assetCount=0
  fi
fi

mkdir -p $TARGET_PATH

for (( index=0; index < $assetCount; index++ )) ; do

  assetId=$(jq -c ".[$index].id" <<< "$filteredAssets")
  assetName=$(jq -r -c ".[$index].name" <<< "$filteredAssets")

  wget -q --auth-no-challenge --header='Accept:application/octet-stream' \
    https://$TOKEN:@api.github.com/repos/$REPOSITORY/releases/assets/$assetId \
    -O $TARGET_PATH/$assetName

  echo "Downloaded $assetName"

done