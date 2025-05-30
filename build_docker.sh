#!/usr/bin/env bash

rm -rf _build/prod

# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=docker mix compile

# Compile assets
# (No assets currently)
# npm install --prefix ./assets
# npm run deploy --prefix ./assets
# mix phx.digest

# Build the release and overwrite the existing release directory
MIX_ENV=docker mix release --overwrite

# Perform any migrations necessary 
# (No migrations currently)
# _build/prod/rel/myApp/bin/myApp eval "MyApp.Release.migrate"

mv _build/docker _build/prod