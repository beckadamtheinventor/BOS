
;@DOES Create a file descriptor with contents stored in RAM.
;@INPUT fs_CreateRamFile(const char *path, uint8_t flags, void *data, size_t len);
;@OUTPUT HL = file descriptor or HL=0 and Cf set if failed.
fs_CreateRamFile:
	call ti._frameset0
	ld hl,(ix+6)
	ld c,(ix+9)
	push bc,hl
	call fs_CreateFileEntry
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail
	pop bc,bc
	ld bc,fsentry_filesector
	add hl,bc
	ex hl,de
	ld hl,(ix+12)
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jq c,.createfile
	ld a,l
	rr h
	rra
	rr h
	rra
	set 7,h ; mark file sector number as a ram offset
	call sys_FlashUnlock
	call sys_WriteFlashA
	ld a,h
	call sys_WriteFlashA
	ld a,(ix+15)
	call sys_WriteFlashA
	ld a,(ix+16)
	call sys_WriteFlashA
	call sys_FlashLock
	jq .done
.createfile:
	add hl,bc
	
.fail:
	or a,a
	sbc hl,hl
	scf
.done:
	ld sp,ix
	pop ix
	ret
