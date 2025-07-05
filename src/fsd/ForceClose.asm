;@DOES Forcefully closes an open file descriptor. Does not write changes or call device deinit.
;@INPUT void fsd_ForceClose(void** fd);
fsd_ForceClose:
	pop bc,hl
	push hl,bc
.entryhl:
assert fsd_OpenFlags = -1
	dec hl
	ld (hl),0 ; close the entry in the table
	inc hl
	push hl
assert fsd_DataPtr = 3
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl) ; high byte of data pointer
	cp a,$D0  ; sets carry flag if a<$D0
	ex (sp),iy
	ld hl,(iy+fsd_DataPtr)
	ld de,(iy+fsd_DataLen)
	pop iy
	ret c ; don't unload if in flash
	jp _DelMem ; unload from ram if in ram
