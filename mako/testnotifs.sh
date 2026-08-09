#!/usr/bin/env bash

if ! makoctl reload; then
    exit $?
fi

if ! (( "$HIDE_URGENCY" )); then
    notify-send -u low 'Urgency Low' 'This is a test message'
    notify-send -u normal 'Urgency Normal' 'This is a test message'
    notify-send -u critical 'Urgency Critical' 'This is a test message'
fi

if ! (( "$HIDE_ICON" )); then
    path=/usr/share/icons/Adwaita
    icon=$(find "$path" -name '*.png' -type f -printf '%f\n' | shuf -n1)
    notify-send -i "$(basename "$icon" .png)" "$icon"
    notify-send -n firefox 'Firefox'
fi

if ! (( "$HIDE_ACTION" )); then
    notify-send -A ok=Ok -A xx=Cancel 'Message with actions' \
        'What do you want to do?'
fi
