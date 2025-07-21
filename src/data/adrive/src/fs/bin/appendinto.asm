
	jr _appendinto_exe
	db "FEX",0
_appendinto_exe:
	ld hl,-6
	call ti._frameset
	ld hl,(bos.LastCommandResult)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail ;fail if 0
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail ;fail if -1
	syscall _argv_1
	push hl
	call bos.fs_OpenFile
	pop de
	ld bc,0
	jq nc,.appendfile
	ld hl,(bos.LastCommandResult)
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push bc,hl
	ld c,0
	push bc,de
	call bos.fs_WriteNewFile
	pop bc,bc,bc
	push af,bc
	call bos.sys_Free
	pop bc,af,bc
	jr .exit_cf ;return -1 if Cf set, or 0 otherwise
.appendfile:
	push hl
	ld bc,bos.fsentry_filelen
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	ld (ix-3),hl ;save old length of file
	push hl
	ld hl,(bos.LastCommandResult)
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (ix-6),bc ;save length of data
	ex (sp),hl ;save pointer to data, restore old length of file
	add hl,bc
	ld de,(ix-3)
	push de
	ld de,$00FFFF
	or a,a
	sbc hl,de
	add hl,de
	jq c,.resize_size_ok ;max file size is 65535, we should reflect that here
	ld hl,(ix-3) ;$00FFFF - old length of file, to calculate length of desired write
	sbc hl,de
	jq z,.fail ;fail if data can't be written
	ld (ix-6),hl ;length of data we can safely write
	ex hl,de
.resize_size_ok:
	push hl
	call bos.fs_SetSize ;increase file size
	pop bc,de,hl
	ld bc,(ix-3)
	push bc,de ;push offset and file descriptor
	ld bc,1
	push bc ;push count
	ld bc,(ix-6)
	push bc,hl ;push len and data
	call bos.fs_Write ;append the data
	call bos.sys_Free
	add hl,bc
	or a,a
	sbc hl,bc
	pop hl,bc,de
	jq z,.fail
	xor a,a
	db $3E ;dummify following scf
.fail:
	scf
.exit_cf:
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

