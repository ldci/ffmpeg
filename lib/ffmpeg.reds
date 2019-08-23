Red/System [
	Title:   "Red and ffmpeg"
	Author:  "Francois Jouen"
	File: 	 %ffmpeg.reds
	Needs:	 View
]

#import [
	LIBC-file cdecl[
		pipe: "pipe" [
			pipedes     [int-ptr!]  "Pointer to a 2 integers array"
			return:     [integer!]
		]
		p-open: "popen" [
			command		[c-string!]
			mode		[c-string!]
			return:		[byte-ptr!]
		]
		p-close: "pclose" [
			file		[byte-ptr!]
			return:		[integer!]
		]
			
		p-read: "fread" [
			data			[byte-ptr!]	
			size			[integer!]
			count			[integer!]
			file			[byte-ptr!]
			return:			[integer!]
		]
			
		p-write: "fwrite" [
			"Write binary array to file."
			array			[byte-ptr!]
			size			[integer!]
			entries			[integer!]
			file			[byte-ptr!]
			return:			[integer!]
		]
		p-flush: "fflush" [
			file			[byte-ptr!]
			return:			[integer!]
		]
	]
]