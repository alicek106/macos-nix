#!/bin/bash
sudo -H darwin-rebuild switch --flake .#"$(scutil --get LocalHostName)"
