#!/usr/bin/env bash
fswatch -o lib/ |  xargs -n1 -I{} mix reload dash@$1