#!/bin/bash

COUNT=$(hyprctl activeworkspace -j | jq '.windows')
notify-send "DEBUG" "Workspace windows: $COUNT"
