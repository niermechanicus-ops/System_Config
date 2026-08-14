#!/usr/bin/env bash
temp=$(sensors -j 2>/dev/null | grep -oP '"Tctl":\{"temp1_input":\K[0-9.]+')
printf '{"text":"%.0f°C","tooltip":"CPU (Tctl)"}\n' "${temp:-0}"
