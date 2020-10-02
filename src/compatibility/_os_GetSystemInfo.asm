
;@DOES return system info. Compatibility define. It actually returns 0xFF0000. lol
_os_GetSystemInfo:
	ld hl,.info
	ret
.info:=$FF0000
;	db 5 dup 0
