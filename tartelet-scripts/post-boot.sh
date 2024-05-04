#!/bin/bash

echo "Fired up $RUNNER_NAME"

osascript <<EOF
    tell application "Terminal"
        activate
        do script "automationmodetool enable-automationmode-without-authentication"
        delay 2
        tell application "System Events"
            keystroke "runner"
            keystroke return
        end tell
    end tell
    delay 5
EOF

echo "Getting terminal windows"
term_service=$(launchctl list | grep -i terminal | cut -f3)
echo "Close terminal windows: gui/501/${term_service}"

if [[ ! "$(automationmodetool)" =~ "DES NOT REQUIRE" ]]; then
	echo "Failed to enable automationmodetool"
	exit 1
fi
