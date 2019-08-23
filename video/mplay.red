Red [
	Title:   "macOS FFMPEG Player"
	Author:  "Francois Jouen"
	File: 	 %rffplay.red
	Needs:	 View
]

fileName: ""
prog: "" 
isFile: false

command: {Basic keys: (complete list in the man page, also check input.conf)
 <-  or  ->			seek backward/forward 10 seconds
 down or up		seek backward/forward  1 minute
 pgdown or pgup	seek backward/forward 10 minutes
 < or >			step backward/forward in playlist
 p or SPACE		pause movie (press any key to continue)
 q or ESC			stop playing and quit program
 + or -			adjust audio delay by +/- 0.1 second
 o				cycle OSD mode:  none / seekbar / seekbar + timer
 * or /			increase or decrease PCM volume
 x or z			adjust subtitle delay by +/- 0.1 second
 r or t				adjust subtitle position up/down, also see -vf expand
}


loadFile: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		isFile: true
		playFile
	]
]

playFile: does [
	if isFile [
		prog: copy "/usr/local/bin/mplayer '" 
		append append prog FileName "'" 
		call/console prog
	]
]

view win: layout/flags/options [
	title "macOS ffplay"
	origin 10x10 space 10x10
	button "Load" [loadFile]
	button "Play" [playFile]
	pad 290x0
	button "Quit" [prog: "killall mplayer" call prog Quit]
	return
	info: area 500x180
	do [info/text: command]
] [resize] [offset: 0x0]
