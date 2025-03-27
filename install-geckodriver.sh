#!/bin/bash

set -euo pipefail

os="$(uname)"
arch="$(uname -m)"
api_token="$token"
api_url="https://api.github.com/repos/mozilla/geckodriver/releases/latest"

if [[ "$os" == "Darwin" ]]; then

  # Add Authorization header if a token is provided
  if [ -n "$api_token" ]; then
    auth_header="Authorization: token $api_token"
  else
    auth_header=""
  fi
  # Make the API request and extract the tag_name
  latest_version=$(curl -s -H "$auth_header" "$api_url" | awk -F'"' '/tag_name/{print $4}')

  if [ -z "$latest_version" ]; then
    echo "Failed to get latest version"
    exit 1
  fi

  echo "Found latest version of geckodriver ${latest_version}"

  mkdir -p geckodriver
  (
    cd geckodriver

    case "$arch" in
      "arm64")
        echo "Downloading geckodriver"
        wget https://github.com/mozilla/geckodriver/releases/download/${latest_version}/geckodriver-${latest_version}-macos-aarch64.tar.gz

        tar xzf geckodriver-${latest_version}-macos-aarch64.tar.gz
        ;;
      "x86_64")
      echo "Downloading geckodriver"
        wget https://github.com/mozilla/geckodriver/releases/download/${latest_version}/geckodriver-${latest_version}-macos.tar.gz
        tar xzf geckodriver-${latest_version}-macos.tar.gz
        ;;
      *)
        echo "Unsupported architecture - $arch"
        exit 1
        ;;
    esac

    chmod +x geckodriver
    echo "geckodriver available at ${PWD}"
  )
  echo "Running geckodriver --version"
  geckodriver/geckodriver --version
  exit 0
else
  echo "Unsupported OS - ${os}"
  exit 1
fi
