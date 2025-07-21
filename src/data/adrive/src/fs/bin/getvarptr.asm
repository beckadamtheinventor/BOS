
	jr getvarptr_main
	db "FEX",0
getvarptr_main:
	call ti._frameset0
	ld a, (ix+6)
	cp a, 2
	jr nz,.help

	syscall _argv_1
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	
	
	
.help:
	ld hl,.helpstr
	call bos.gui_PrintLine
	ld hl,1
	ret

.helpstr:
	db "getvarptr var",$A,$9,"Return the address var is stored at.",0

