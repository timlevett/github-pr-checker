#!/usr/bin/env bash

echo "repo : $1"
echo "key  : $2"
echo "team : $3"
echo "org  : $4"
cp Dockerfile Dockerfile.bac

sed -i.bak "s/GHKEY/$2/g" Dockerfile
sed -i.bak "s/GHTEAM/$3/g" Dockerfile
sed -i.bak "s/GHORG/$4/g" Dockerfile
docker build -t github-pr-check .
docker tag github-pr-check:latest $1/github-pr-check:latest
docker push $1/github-pr-check:latest

mv Dockerfile Dockerfile.backup
mv Dockerfile.bac Dockerfile
rm Dockerfile.bak