#!/bin/sh

use-wptl latest
if [ -d node_modules ]; then
    npm install
else
    npm ci
fi
