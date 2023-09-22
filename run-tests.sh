#!/usr/bin/env sh

set -o allexport
. .env

# Run tests
artillery run -o report__get-all-entries.json test-get-all-toolbox-entries.yaml
artillery run -o report__search-short-field.json test-search-toolbox-items-short-text.yaml
artillery run -o report__search-long-field.json test-search-toolbox-items-long-text.yaml
