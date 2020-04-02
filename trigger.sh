#!/bin/bash

cat << RUBY | ruby -r json
source =
  if ENV["TRAVIS_COMMIT_MESSAGE"].to_s =~ /\AMerge pull request (#\d+)/
    "#{ENV["TRAVIS_REPO_SLUG"]}#{\$1}"
  else
    "#{ENV["TRAVIS_REPO_SLUG"]}@#{ENV["TRAVIS_COMMIT"]} (#{ENV["TRAVIS_BRANCH"]})"
  end

user_name, user_email, commit_message =
  \`git log -1 --pretty=format:"%aN%x00%aE%x00%B"\`.split("\0")

File.write("/tmp/post.json", {
  "request" => {
    "branch"  => "build",
    "message" => "Deployed site for #{source}",
    "config"  => {
      "merge_mode" => "deep_merge",
      "env"        => {
        "global" => [
          "SOURCE_REPO_INFO"      => source,
          "SOURCE_USER_NAME"      => user_name,
          "SOURCE_USER_EMAIL"     => user_email,
          "SOURCE_COMMIT_MESSAGE" => commit_message,
        ]
      }
    }
  }
}.to_json)
RUBY

curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token $TRAVIS_TOKEN" \
  -d @/tmp/post.json \
  https://api.travis-ci.com/repo/ManageIQ%2Fmanageiq.github.io/requests
