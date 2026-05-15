#Requires AutoHotkey v2.0
#SingleInstance Force

; WSL-managed AutoHotkey config.
; Runs elevated so hotkeys can affect administrator windows too.

if !A_IsAdmin {
	Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
	ExitApp
}

; Reload this script with Ctrl+Alt+R.
^!r::Reload

; Open WezTerm with Win+Enter.
#Enter::Run "wezterm-gui.exe"

; Focus workspace 6 and open/move Spotify with Win+M. This overrides Windows minimize-all.
#m:: {
	spotify := "C:\Users\shahid\AppData\Roaming\Spotify\Spotify.exe"
	KeyWait "m"
	Send "{LWin up}{RWin up}"
	Sleep 50
	Send "#6"
	Sleep 150

	if ProcessExist("Spotify.exe") {
		if WinExist("ahk_exe Spotify.exe") {
			WinActivate "ahk_exe Spotify.exe"
			WinWaitActive "ahk_exe Spotify.exe", , 2
			Send "#+6"
			Sleep 100
			Send "#6"
		} else if FileExist(spotify) {
			Run spotify
			WinWait "ahk_exe Spotify.exe", , 10
			WinActivate "ahk_exe Spotify.exe"
			WinWaitActive "ahk_exe Spotify.exe", , 2
			Send "#+6"
			Sleep 100
			Send "#6"
		}
	} else if FileExist(spotify) {
		Run spotify
		WinWait "ahk_exe Spotify.exe", , 10
		WinActivate "ahk_exe Spotify.exe"
		WinWaitActive "ahk_exe Spotify.exe", , 2
		Send "#+6"
		Sleep 100
		Send "#6"
	}
}

; Open Task Manager with Ctrl+Shift+Esc.
^+Esc::Run "taskmgr.exe"

; Close active window with Win+Q. Spotify can hang on graceful close after Spicetify injection.
#q:: {
	if WinActive("ahk_exe Spotify.exe") {
		RunWait "taskkill.exe /IM Spotify.exe /F", , "Hide"
	} else {
		WinClose "A"
	}
}

; Esc acts as CapsLock.
Esc::CapsLock

; CapsLock acts as Ctrl when held and Esc when tapped.
*CapsLock:: {
	Send "{Blind}{Ctrl down}"
	KeyWait "CapsLock"
	Send "{Blind}{Ctrl up}"

	if (A_PriorKey = "CapsLock")
		Send "{Esc}"
}
