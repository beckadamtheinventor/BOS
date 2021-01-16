
;@DOES execute a file
;@INPUT int sys_ExecuteFile(char *path, char *args);
;@OUTPUT -1 if file does not exist or is not a valid executable format
;@OUTPUT ExecutingFileFd set to point to file descriptor. -1 if file not found
;@DESTROYS All, OP6.
sys_ExecuteFile:
	scf
	sbc hl,hl
	ld (ExecutingFileFd),hl
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.fail
	ld (fsOP6),de
	push hl
	call fs_OpenFile
	jq c,.fail_popbc
.open_fd:
	ld (ExecutingFileFd),hl
	ld bc,$B
	add hl,bc
	bit 4,(hl)
	ld hl,(ExecutingFileFd)
	pop bc
	jq nz,.fail
	ld de,fsentry_filesector
	add hl,de
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	push hl
	ld a,(hl)
	cp a,$18 ;jr
	jq z,.skip2
	cp a,$C3 ;jp
	jq z,.skip4
.fail_popbc:
	pop bc
.fail:
	scf
	sbc hl,hl
	ret
.skip4:
	inc hl
	inc hl
.skip2:
	inc hl
	inc hl
	ld a,(hl)
	cp a,$EF
	jq z,.check_ef7b
	ld de,(hl)
	db $21 ;ld hl,...
	db 'FEX' ;Flash EXecutable
	or a,a
	sbc hl,de
	jq z,.exec_fex
	db $21 ;ld hl,...
	db 'REX' ;Ram EXecutable
	or a,a
	sbc hl,de

	jq nz,.fail_popbc ;if it's neither a Flash Executable nor a Ram Executable, return -1

.exec_rex:
	pop hl      ;file data pointer (not needed, this is re-handled in fs_Read)
	ld iy,(ExecutingFileFd) ;file descriptor
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	pop bc
	push hl
	ld hl,(iy+fsentry_filelen)
	ex.s hl,de
	push de
	pop bc
	pop hl
	ld de,bos_UserMem
	push de ;save jump address
	ld (asm_prgm_size),bc
	push bc ;save program size
	ldir
	pop bc
	pop hl  ;usermem
	push hl
	add hl,bc
	ld (top_of_UserMem),hl ;save top of usermem
.exec_fex:
	ld hl,(fsOP6)
	ex (sp),hl ;push arguments to stack, pop jump location from the stack
.run_hl:
	call .normalize_lcd
	call .jphl
	pop bc
	push hl
	call .normalize_lcd
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	call sys_FreeAll
	pop hl
	ret
.jphl:
	jp (hl)

.check_ef7b:
	inc hl
	ld a,(hl)
	cp a,$7B
	jq nz,.fail_popbc
	jq .exec_rex
	
.normalize_lcd:
	ld bc,ti.vRam
	ld (ti.mpLcdUpbase),bc
	ld a,ti.lcdBpp8
	ld (ti.mpLcdCtrl),a
	ret


