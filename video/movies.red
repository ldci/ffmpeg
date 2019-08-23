Red [
	Title:   "Red and ffmpeg"
	Author:  "Francois Jouen"
	File: 	 %movies.red
	Needs:	 View
]

w: 720
h: 480
fps: 30
tfps: 1 / to-float fps 

fileName: "Untitled.mpg"
isFile: false
isReading: false
nFrames: 100
frameDur: 0.0
index: 1
appDir: to-file get-current-dir
tmpd: copy form  appDir
append tmpd "tmpffmpeg/"
dataDir: to-file tmpd
margins: 5x5

; for Unicode string with images
makeUnicodeStr: func [s [string!] c [char!] return: [string!]][
	rejoin [s form c]
]

s1: makeUnicodeStr "" #"^(23EE)"	;First frame
s2: makeUnicodeStr "" #"^(23EA)"	;Next frame
s3: makeUnicodeStr "" #"^(23E9)"	;Previous frame
s4: makeUnicodeStr "" #"^(23ED)"	;Last frame
s5: makeUnicodeStr "" #"^(23EF)"	;Play/Stop movie


generateCommands: func [] [
	blk: rejoin [
		"/usr/local/bin/ffmpeg" 	;location of ffmepg binary (to be adaptated according your OS)
		" -y"						;replace files
		" -i '" fileName "'"		;source movie				
		" -f image2" 				;The image file muxer writes video frames to image files (auto detect by extension).	
		" -s 720x480"				;output size	
		" -q:v 1"					;use fixed quality scale (1 to 31, 1 is highest)
		" -r " fps					;fps (mandatory for .vmw files)
		" " dataDir					;temp destination directory
		"img-%05d.jpg"				;automatic file name numbering																		
	]
	form blk						;returns command line string
]

cleanDir: does [
	clear list/data
	do-events/no-wait
	d: read dataDir
	foreach v d [
		fn: rejoin [copy dataDir v]	
		if exists? fn [delete fn]
	]
	fn: none
]

getImages: does [
	cleanDir								;suppress previous images
	call/console/wait generateCommands 		;ffmpeg needs the console (CLI Mode)
	list/data: sort read dataDir			;read the result
	list/selected: 1						;first image
	nFrames: length? list/data
	nF/text: rejoin [form nFrames " frames"]
	movDur: nFrames / to-float fps
	frameDur: movDur / nFrames
	df/text: rejoin [form round/to movDur 0.01 " sec"]
	index: 1
]

loadMovie: does [
	tmp: request-file/filter 
		["Supported Video Files [mpg mp4 mkv avi wmv mov]" 
		"*.mpg";"*.mp4"; "*.mkv"; ".avi";".wmv" ".mov"
	]
	if not none? tmp [
		tmpd: copy form  first split-path tmp
		append tmpd "tmpffmpeg/"
		dataDir: to-file tmpd
		;create dataDir where movies are
		if not exists? dataDir [make-dir dataDir]
		canvas/Image: none
		fileName: form tmp
		sb/text: "Be patient! Loading Movie..."
		getImages
		isReading: false
		isFile: true
		sb/text: form tmp
	]
]

loadImage: func [idx [integer!]] [
	if isFile [
		canvas/image: load to-file rejoin [form dataDir list/data/:idx]
		index: idx
	]
]

upDateFaces: does [
	niF/text: form index
	sl/data: to-percent index / (nFrames - 1.0) 
	fdF/text: form round/to (frameDur * index) 0.01
]

view win: layout [
	title "Reading video with Red and ffmpeg"
	origin margins space margins
	box 30x20 "FPS"  
	fpsF: field 50 "30" [
			if error? try [fps: to-integer face/text] [fps: 25]
			tfps: 1 / to-float fps 
			cleanDir 
			getImages
	]
	button "Load" 	[loadMovie]
	sb: box 380x20 white left ""
	nF: box 90x20  white right
	dF: box 80x20  white right
	pad 50x0
	button "Quit" 	[if exists? datadir [cleanDir delete dataDir] 
					call/wait "killall ffmpeg" quit]
	return
	canvas: base 720x480 black
	list: text-list 120x480 
		on-change [
			idx: list/selected
			canvas/image: load to-file rejoin [form dataDir list/data/:idx]
			index: idx
			upDateFaces
		]
	return
	
	b1: text 30x30 font-size 20 s1 [index: 1 loadImage index upDateFaces] 
	
	b2: text 30x30 font-size 20 s2 [index: index - 1 if index < 1 [index: 1]
									loadImage index upDateFaces] 
	
	b5: text 30x30 font-size 20 s5  
		[either isReading 
						[face/rate: none isReading: false list/visible?: true] 
						[face/rate: to-time reduce [0 0 tfps] list/visible?: false 
					isReading: true]
		]
		on-time [loadImage index upDateFaces index: index + 1 
			if index > nFrames [index: nFrames face/rate: none list/visible?: true]
		]
	b3: text 30x30 font-size 20 s3 [index: index + 1  if index > nFrames [index: nFrames] 
									loadImage index upDateFaces]
	b4: text 30x30 font-size 20 s4 [index: nFrames loadImage index upDateFaces] 
	sl: slider 415 [
		if isFile [
			index: 1 + to-integer (face/data * nFrames - 1)
			if index < 1 [index: 1]
			niF/text: form index
			fdF/text: form round/to (frameDur * index) 0.01
			loadImage index
		]
	]
	niF: box 60x20 white right "0"
	fdF: box 60x20 white right "0"
]

