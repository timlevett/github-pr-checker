#!/usr/bin/env bash

sed -i.bak "s/GHKEY/$2/g" Dockerfile
sed -i.bak "s/GHTEAM/$3/g" Dockerfile
sed -i.bak "s/GHORG/$4/g" Dockerfile
docker build -t github-pr-check .
docker tag github-pr-check:latest $1/github-pr-check:latest
docker push $1/github-pr-check:latest
