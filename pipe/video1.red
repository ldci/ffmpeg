Red [
	Title:   "Red and ffmpeg"
	Author:  "Francois Jouen"
	File: 	 %video1.red
	Needs:	 View
]

;we need Red/System for pipe 
#system [
	#include %../lib/ffmpeg.reds
]

processImages: routine [
	buf			[vector!]
	commandr	[string!]
	commandw	[string!]
	/local 
	cmdr		[c-string!]
	cmdw		[c-string!]
	pipeIn  	[byte-ptr!]
	pipeOut  	[byte-ptr!]
	frame 		[byte-ptr!]	
	count		[integer!]
	tvalue		[integer!]
	n			[integer!]
][
	;a vector array to store frame by frame
	frame: vector/rs-head buf
	count:  vector/rs-length? buf
	tValue: count
	cmdr: as c-string! string/rs-head commandr
	cmdw: as c-string! string/rs-head commandw
	;Open input and output pipes from ffmpeg
	pipeIn:  p-open cmdr "r" 
	pipeOut: p-open cmdw "w" 
	while [count = tValue] [
		;Read a frame from the input pipe into the buffer
		count: p-read frame 1 tValue pipeIn
		if count <> tValue [break]
		;Process the current frame
		n: 0 
		while [n < count] [
			;Invert each colour component in every pixel
			frame/n: as byte! (255 - frame/n)
			n: n + 1
		]
		;write frame to the output pipe
		p-write frame 1 tValue pipeOut
	]
	p-flush pipeIn p-flush pipeOut
	p-close pipeIn p-close pipeOut
]


srcName: "Homer.mp4"
dstName: "Homer2.mp4"
tmpName: "tmp.mp4"
imageSize: 646x480 

buffer: make vector! [char! 8 930240] ; w * h * 3 

ffmpegr: rejoin [
	"/usr/local/bin/ffmpeg"	;location of ffmepg binary
	" -i '" srcName	"'"		;source name
	" -f image2pipe"		;image file muxer writes video frames to pipe 
	" -pix_fmt rgb24"		;rgb values
	" -vcodec rawvideo"		;raw data
	" -"					;for pipe
]

ffmpegw: rejoin [
	"/usr/local/bin/ffmpeg" ;location of ffmepg binary
	" -y" 					;replace file if exists
	" -f rawvideo"			;raw data
	" -vcodec rawvideo" 	;raw data
	" -pix_fmt rgb24" 		;rgb values
	" -s " imageSize 		;output size
	" -r 29"				;FPS (3000/1001)
	" -i -"					;we use a pipe 
	" -f mp4"				;mp4 format
	" -q:v 1"				;best image quality
	" -an" 					;no sound
	" -vcodec mpeg4" 		;video codec
	" '" tmpName "'"		;output name
]

;********************** Main ***********************************

print "Processing video ..."
processImages buffer ffmpegr ffmpegw
print "Done"
print "Getting source audio ..."
call/wait rejoin ["ffmpeg -i " srcName " -vn tmp.mp3"]
print "Updating destination audio..."
call/wait rejoin ["ffmpeg -i tmp.mp3 -i '" tmpName "'" "'" dstName "'"]
if exists? %tmp.mp4 [delete %tmp.mp4]
if exists? %tmp.mp3 [delete %tmp.mp3]
print "Playing movie"
call/wait rejoin ["ffplay "  dstName]





