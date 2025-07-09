#!/usr/bin/env bash
echo "Script name: $0"
echo "Number of args: $#"
echo "All args: $@"
for i in "$@"; do
    echo "Arg: $i"
done