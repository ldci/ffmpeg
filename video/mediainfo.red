Red [
	Title:   "FFMPEG Player"
	Author:  "Francois Jouen"
	File: 	 %mediainfo.red
	Needs:	 View
]

fileName: ""
fn: ""
prog: "" 
isFile: false
outPut: %meta.txt
mode: "default"

margins: 5x5

generateCommands: func [] [
	blk: rejoin [
		"/usr/local/bin/ffprobe"	
		" -show_format"
		" -show_streams"
		" -print_format " mode
		" -i '" fileName "'"							
	]
	form blk									
]



readOutPut: does [
	call/wait/output prog outPut
	info/text: read outPut
	delete outPut
]


loadFile: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		movDir: first split-path tmp
		fn: to-string second split-path tmp
		outPut: rejoin [movDir %meta.txt]
		either cb/data [sb/text: copy fileName] [sb/text: copy fn]
		isFile: true
		prog: generateCommands
		readOutPut
	]
]

view win: layout[
	title "Media Infos [ffprobe]"
	origin margins space margins
	origin 10x10 space 10x10
	button 50 "Load" 			[loadFile]
	cb: check "Show directory" 	[either face/data [sb/text: copy fileName] [sb/text: copy fn]]
	text 40 "Mode" 
	dp: drop-down 70 data ["default" "flat" "ini" "json" "xml"]
		on-change [mode: face/data/(face/selected)  
			if isFile [prog: generateCommands readOutPut]
		]
		select 1
	button 30 "+"  			[fs/data: fs/data + 1]
	fs: field 30 "12" 		react [info/font/size: fs/data]
	button 30 "-"  			[fs/data: max 1 fs/data - 1]
	button 50 "Quit" 		[prog: "killall ffprobe" call prog Quit]
	return
	info: area 500x300 font [name: "Arial" size: 12 color: black] 
	return
	sb: base 500x20	white
]
