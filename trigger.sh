#!/bin/bash

cat << RUBY | ruby -r json
target =
  if ENV["TRAVIS_COMMIT_MESSAGE"].to_s =~ /\AMerge pull request (#\d+)/
    "#{ENV["TRAVIS_REPO_SLUG"]}#{\$1}"
  else
    "#{ENV["TRAVIS_REPO_SLUG"]}@#{ENV["TRAVIS_COMMIT"]} (#{ENV["TRAVIS_BRANCH"]})"
  end
File.write("/tmp/post.json", {
  "request" => {
    "branch"  => "build",
    "message" => "Deployed site for #{target}"
  }
}.to_json)
RUBY

curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token $TRAVIS_TOKEN" \
  -d @/tmp/post.json \
  https://api.travis-ci.org/repo/ManageIQ%2Fmanageiq.github.io/requests
