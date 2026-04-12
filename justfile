set shell := ["pwsh.exe", "-NoProfile", "-c"]

default: help

# Help
help:
    @just --list

# Check markdown linting
check-md:
    @pnpx markdownlint-cli2

# Fix markdown linting
fix-md:
    @pnpx markdownlint-cli2 --fix