
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
	pop bc
	jq c,.fail
.open_fd:
	ld (ExecutingFileFd),hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit 4,(hl)
	ld hl,(ExecutingFileFd)
	jq nz,.fail ;can't execute a directory
	ld de,fsentry_filesector
	add hl,de
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	ld (fsOP6+3),hl
.exec_check_loop:
	ld a,(hl)
	inc hl
	cp a,$18 ;jr
	jq z,.skip1
	cp a,$C3 ;jp
	jq z,.skip3
	cp a,$EF
	jq nz,.fail
	ld a,(hl)
	inc hl
	cp a,$7B
	jq z,.exec_rex_entryhl
.fail:
	scf
	sbc hl,hl
	ret
.skip3:
	inc hl
	inc hl
.skip1:
	inc hl
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
	jq nz,.fail ;if it's neither a Flash Executable nor a Ram Executable, return -1

.exec_rex:
	ld iy,(ExecutingFileFd) ;file descriptor
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	pop bc
.exec_rex_entryhl:
	push hl
	ld hl,(iy+fsentry_filelen)
	ex.s hl,de
	push de
	pop bc
	pop hl
	ld de,bos_UserMem
	push de ;save jump address
	ld (asm_prgm_size),bc
	push bc
	ldir
	pop bc
	pop hl  ;usermem
	ld (fsOP6+3),hl
	add hl,bc
	ld (top_of_UserMem),hl ;save top of usermem
.exec_fex:
	ld hl,(fsOP6) ;push arguments
	push hl
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
	ld hl,(fsOP6+3)
	jp (hl)
.normalize_lcd:
	ld bc,ti.vRam
	ld (ti.mpLcdUpbase),bc
	ld a,ti.lcdBpp8
	ld (ti.mpLcdCtrl),a
	ret


