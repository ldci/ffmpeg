Red [
	Title:   "macOS FFMPEG Player"
	Author:  "Francois Jouen"
	File: 	 %rffplay.red
	Needs:	 View
]

fileName: ""
prog: "" 
isFile: false

command: {List of commands while running
q, ESC: Quit.
f: Toggle full screen.
p, SPC: Pause.
m: Toggle mute.
9, 0:  Decrease and increase volume respectively.
/, *: Decrease and increase volume respectively.
a: Cycle audio channel in the current program.
v: Cycle video channel.
t: Cycle subtitle channel in the current program.
c: Cycle program.
w: Cycle video filters or show modes.
s: Step to the next frame.
left/right: Seek backward/forward 10 seconds.
down/up: Seek backward/forward 1 minute.
page down/page up :Seek to the previous/next chapter. or if there are no chapters Seek backward/forward 10 minutes.
right mouse click: Seek to percentage in file corresponding to fraction of width.
left mouse double-click: Toggle full screen.
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
		prog: copy "/usr/local/bin/ffplay -autoexit '" 
		append append prog FileName "'" 
		call/shell prog
	]
]

view win: layout/flags/options [
	title "macOS ffplay"
	origin 10x10 space 10x10
	button "Load" [loadFile]
	button "Play" [playFile]
	pad 290x0
	button "Quit" [prog: "killall ffmpeg" call prog Quit]
	return
	info: area 500x280
	do [info/text: command]
][resize] [offset: 0x0]
