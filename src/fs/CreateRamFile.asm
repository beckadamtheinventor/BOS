
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
	push hl
	ld hl,(ix+12)
	call _AddVATEntry
	jq c,.fail
	pop de
	ld hl,(ix+12)
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,.fail
	add hl,bc
	push de
	call _GetVATEntryNFromPtr
	pop de
	ld a,h
	add a,$E0
	cp a,h
	jr nc,.fail ; if the new value is less than the old value, the VAT entry number is higher than $1FFF, which causes an overflow
	ld (ix+17),a
	ld a,l
	call sys_FlashUnlock
	call sys_WriteFlashA
	ld a,(ix+17)
	call sys_WriteFlashA
	ld a,(ix+15)
	call sys_WriteFlashA
	ld a,(ix+16)
	call sys_WriteFlashA
	xor a,a
	ld (ix+17),a
	call sys_FlashLock
	jr .done
.fail:
	or a,a
	sbc hl,hl
	scf
.done:
	ld sp,ix
	pop ix
	ret
