#!/usr/bin/osascript
tell application "System Events"
	tell application "Dictionaries" to activate
	repeat until (exists window 1 of application process "Dictionaries")
		delay 0.1
	end repeat
	keystroke "n" using {shift down, command down}
	keystroke (system attribute "QUTE_SELECTED_TEXT")
	delay 0.5
	key code 36
end tell