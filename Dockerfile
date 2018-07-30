FROM appropriate/curl

RUN apk add --update jq && apk add --update bash && rm -rf /var/cache/apk/*
COPY ./github-fetch-all-teams-open-pr.sh /entrypoint.sh
CMD ["/entrypoint.sh", "GHKEY", "GHTEAM", "/tmp/prs", "GHORG"]
