#!/bin/sh

use-wptl latest
if [ -d node_modules ]; then
    npm install
else
    npm ci
fi

if npm ls playwright > /dev/null; then
    npx playwright install
fi
