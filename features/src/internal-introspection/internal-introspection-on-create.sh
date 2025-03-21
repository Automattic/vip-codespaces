#!/bin/sh

{ env | sort; echo; echo; } >> /usr/local/etc/vscode-dev-containers/vip-codespaces/internal-introspection/on-create.env
