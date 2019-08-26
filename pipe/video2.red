Red [
	Title:   "Red and ffmpeg"
	Author:  "Francois Jouen"
	File: 	 %video2.red
	Needs:	 View
]

w: 720
h: 480
im:  none
img: make image! reduce [as-pair w h black]
prog: copy ""
isFile: false
delay: 0.025
;we need Red/System for pipe commands
#system [
	#include %../lib/ffmpeg.reds
	RSdelay: 0.025 ; RS variable
]

waitfor: func [
	n	[float!]
][
	wait n
]

showImage: func [] [
	im/image: img
	do-events/no-wait
]

getImages: routine [
	command	[string!]
	rimage	[image!]
	delay 	[float!]
	/local 
	cmd		[c-string!]
	pipeIn  [byte-ptr!]
	frame 	[byte-ptr!]
	pixD 	[int-ptr!]
	count	[integer!]
	n		[integer!]
	handle  [integer!]
	w		[integer!]
	h		[integer!]
	r 		[integer!]
	g 		[integer!]
	b		[integer!]
][
	RSdelay: delay
	w: IMAGE_WIDTH(rimage/size)
	h: IMAGE_HEIGHT(rimage/size)
	count: (h * w * 3)
	;Allocate a buffer to store frame by frame
	frame: allocate count ;* 2
	cmd: as c-string! string/rs-head command
	;Open input pipe from ffmpeg
	pipeIn: p-open cmd "r" 
	if pipeIn <> null [
		while [count = (h * w * 3)][
			;Read a frame from the input pipe into the buffer
			count: p-read frame 1 h * w * 3 pipeIn
			if count <> (h * w * 3) [break]
			if count = (h * w * 3)[
				handle: 0
				pixD: image/acquire-buffer rimage :handle
				n: 0 
				while [n < count] [
					r: (as integer! frame/n)
					n: n + 1
					g: (as integer! frame/n) 
					n: n + 1
					b: (as integer! frame/n)
					n: n + 1
					; for a correct rendering in Red 
					pixD/value: (255 << 24) OR (r << 16 ) OR (b << 8) OR g
					pixD: pixD + 1	
				]
				image/release-buffer rimage handle yes
				#call [waitfor RSdelay]
				#call [showImage]
			]	
		]
		free frame
		p-flush pipeIn
		p-close pipeIn 
	]
]

loadMovie: does [
	tmp: request-file
	if not none? tmp [
		fileName: form tmp
		sb/text: form second split-path tmp
		audio: form  rejoin [first split-path tmp "tmp.mp3"]
		isFile: true
		call/wait rejoin ["/usr/local/bin/ffmpeg -i '" fileName "' -vn " audio]
		prog: generateCommands 
		if cb/data [call rejoin ["/usr/local/bin/ffplay -showmode 0 " audio]]
		getImages prog img delay
		call/wait "killall ffplay"
		if exists? to-file audio [delete to-file audio]
	]
]

generateCommands: func [] [
	blk: copy []
	blk: rejoin [
		"/usr/local/bin/ffmpeg" 	;location of ffmepg binary
		" -i '" fileName "'"		;source movie	
		" -s 720x480"				;output size				
		" -f image2pipe" 			;The image file muxer writes video frames to pipe
		" -pix_fmt bgr24"			;use bgr for read
		" -vcodec rawvideo"			;raw data 
		" -"						;for pipe command												
	]
	form blk						;command line string
]

; **************************** Main ***************************************
view win: layout [
	title "Read Video with pipe"
	button "Load" [loadMovie]
	cb: check "Audio" true
	sl: slider 100 [delay: to-float face/data * 0.10 fD/text: form round/to delay 0.001]
	fD: field 50 "0.025"
	pad 320x0
	button "Quit" [call/wait "killall ffplay" quit]
	return
	im: image 720x480 img
	return
	sb: field 720 ""
	do [sl/data: 25%]
]

