#!/bin/bash

HASH=$1
AUTH_KEY=$2
TEAM=$3
TEMP_DIR=$4
ORG=$5

SILENT="-s"
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

# get team id
TEAM_ID=`curl ${SILENT} -H "Authorization: token $AUTH_KEY" https://api.github.com/orgs/$ORG/teams | jq ".[] | select(.name == \"${TEAM}\") | .id"`

#echo "Team ID for $TEAM is $TEAM_ID"

# pull repos for team TODO: paginate automagically
REPOS1=`curl ${SILENT} -H "Authorization: token $AUTH_KEY" "https://api.github.com/teams/${TEAM_ID}/repos?per_page=100&page=1" | jq ".[] | .pulls_url"`
REPOS2=`curl ${SILENT} -H "Authorization: token $AUTH_KEY" "https://api.github.com/teams/${TEAM_ID}/repos?per_page=100&page=2" | jq ".[] | .pulls_url"`
REPOS="$REPOS1 $REPOS2"
echo "$TEAM PRS; Scanning `echo $REPOS | grep -o " " | wc -l` repos."

# pull pull requests that are open for each project
for REPO in $REPOS; do
  PULL_URL=`echo $REPO | cut -f1 -d"{" | cut -f2 -d"\""`
  #echo $PULL_URL
  REPO_OPEN_PRS=`curl ${SILENT} -H "Authorization: token $AUTH_KEY" $PULL_URL?state=open | jq ".[] | [{ url: .html_url , created: .created_at , user: .user.login, title: .title }]"`
  if [ "" != "$REPO_OPEN_PRS" ]; then
    echo $REPO_OPEN_PRS > $TEMP_DIR/`echo ${REPO:42} | cut -f1 -d"/"`.json
    # echo $REPO_OPEN_PRS
  fi
done

jq -s '[.[]]|flatten' $TEMP_DIR/*.json | jq 'sort_by(.created)' | jq '.[] | "• " + .user + " " + .title + " (" + .url + ")"' | cut -f2 -d"\"" | cut -f1 -d"\"" | grep -v "WIP"
rm -rf $TEMP_DIR
