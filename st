#!/usr/bin/env bash
schedtool -B -n 1 -e ionice -n 1 "$@"
