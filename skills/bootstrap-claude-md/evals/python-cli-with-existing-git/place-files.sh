#!/usr/bin/env bash
set -eu
git init -q
printf '.venv/\n__pycache__/\n' > .gitignore
