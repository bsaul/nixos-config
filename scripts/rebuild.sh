#! /usr/bin/env bash
# Copies system configurations to /etc/nixos
# then rebuilds system

sudo cp -r ~/nixos-config/system/* /etc/nixos/ && sudo nixos-rebuild switch
