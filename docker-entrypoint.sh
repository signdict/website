#!/bin/sh
cd /signdict

echo "============" deps
mix local.hex --force && mix local.rebar --force
mix deps.get


echo "============" setup
mix ecto.setup

echo "============" yarn
cd assets
yarn install --force
cd ..

echo "============" start server
mix phx.server
