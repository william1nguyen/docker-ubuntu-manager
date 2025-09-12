#!/bin/bash

google-chrome-stable \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --disable-software-rasterizer \
  --disable-background-timer-throttling \
  --disable-backgrounding-occluded-windows \
  --disable-renderer-backgrounding \
  --disable-features=VizDisplayCompositor \
  --disable-extensions \
  --disable-plugins \
  --disable-default-apps \
  --disable-translate \
  --disable-logging \
  --disable-crash-reporter \
  --disable-breakpad \
  --no-crash-upload \
  --no-default-browser-check \
  --no-first-run \
  --no-pings \
  --no-experiments \
  --disable-web-security \
  --allow-running-insecure-content \
  --disable-features=TranslateUI \
  --disable-ipc-flooding-protection \
  --disable-hang-monitor \
  --disable-prompt-on-repost \
  --disable-domain-reliability \
  --disable-component-update \
  --disable-background-networking \
  --user-data-dir=/tmp/chrome-user-data \
  "$@" > /dev/null 2>&1 &