#!/bin/bash
find . -maxdepth 1 ! -name 'copy_from_claude.sh' ! -name '.' ! -name '.git' -exec rm -rf {} +
cp -r ~/.claude/skills/ ./
