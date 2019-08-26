Red [
	Title:   "Sound and ffmpeg"
	Author:  "Francois Jouen"
	File: 	 %sound2.red
	Needs:	 View
]
;we need Red/System for pipe 

;we need Red/System for pipe 
#system [
	#include %../lib/ffmpeg.reds
]
; Generate 1 second of audio data: 1 kHz sine wave
generateSound: does [
	i: 1
	while [i <= n] [
		buf/:i: to-integer (16383.0 * sin i * 1000.0 * 2 * pi / f)
		i: i + 1
	]
]

;call pipe subprocess
makePipe: routine [
	command	[string!]
	array 	[vector!]
	/local 
	cmd		[c-string!]
	pipeout [byte-ptr!]
	ptr 	[byte-ptr!]
	n		[integer!]
][
	cmd: as c-string! string/rs-head command
	ptr: as byte-ptr! vector/rs-head array
	n: 	 vector/rs-length? array
	;Pipe the audio data to ffmpeg, which writes it to a wav file
	pipeout: p-open cmd "w" 
	p-write ptr 2 n pipeout
	p-close pipeout 
]
; ************************ Main ******************************
n: 44100								;Sample number (1 sec)
f: 44100.0								;sound frequency 
buf: make vector! [integer! 16 44100]	;16-bit array 
; FFmpeg commands
prog: "ffmpeg -y -f s16le -ar 44100 -ac 1 -i - 'beep.wav'"

print "Generating 1 kHz sine wave..."
generateSound buf n f
makePipe prog buf
print "Done" 
call "ffplay -hide_banner -showmode 1 'beep.wav'"











   