;@DOES check the filesystem for errors. Attempts to fix if there are any. If that fails, it reformats the filesystem.
;@DESTROYS All
fs_SanityCheck:
	ld hl,fs_filesystem_address
	ld a,$FF
	ld bc,$010000 ;if there's 64k of unwritten data, the filesystem hasn't been formatted yet
.check_loop_1:
	cpi
	jp po,fs_Format
	jr z,.check_loop_1
	
	
	ret
