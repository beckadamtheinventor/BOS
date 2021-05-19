
;@DOES execute a file given a relative or absolute path
;@INPUT int sys_ExecuteFile(const char *path, char *args);
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
.entryhlde:
	ld a,(hl)
	or a,a
	jq z,.fail
	ld (fsOP6),de
	push hl
	call fs_AbsPath
	ex (sp),hl
	call fs_OpenFile
	pop bc
	jq c,.fail
.open_fd:
	ld (ExecutingFileFd),hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_subdir,(hl)
	jq nz,.fail ;can't execute a directory
	bit fsbit_subfile,(hl)
	inc hl
	ld de,(hl)
	jq z,.get_file_ptr
	push hl
	ex.s hl,de
	pop de
	ld e,0
	res 0,d
	add hl,de
	jq .got_file_ptr
.get_file_ptr:
	push de
	call fs_GetSectorAddress
	pop bc
.got_file_ptr:
	ld (running_program_ptr),hl
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
	db 'CRX' ;Compressed Ram eXecutable
	or a,a
	sbc hl,de
	jq z,.exec_compressed_rex
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
	ld hl,(running_program_ptr)
.exec_rex_entryhl:
	push hl
	ld hl,(iy+fsentry_filelen)
	ex.s hl,de
	push de
	pop bc
	pop hl
	ld de,bos_UserMem
	push de ;save jump address
	push bc
	ldir
	pop bc
.exec_setup_usermem_bc:
	ld (asm_prgm_size),bc
	ld hl,top_of_RAM-$010000
	ld (free_RAM_ptr),hl
	ld de,-bos_UserMem
	add hl,de
	ld (remaining_free_RAM),hl
	pop hl  ;usermem
	ld (running_program_ptr),hl
	add hl,bc
	ld (top_of_UserMem),hl ;save top of usermem
.exec_fex:
	ld hl,(fsOP6) ;push arguments
	push hl
	call sys_NextProcessId
	call sys_FreeRunningProcessId ;free memory allocated by the new process ID, though there shouldn't be any in the first place
	call .normalize_lcd
	call .jptoprogram
	pop bc
	push hl
	call .normalize_lcd
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	call sys_FreeRunningProcessId ;free memory allocated by the program
	call sys_PrevProcessId
	pop hl
	ret
.exec_compressed_rex:
	ld hl,(running_program_ptr)
	ld a,(hl)
	cp a,$18 ;jr
	jq z,.compressed_rex_skip2
	cp a,$C3 ;jp
	jq nz,.fail
.compressed_rex_skip4:
	inc hl
	inc hl
.compressed_rex_skip2:
	ld bc,6
	add hl,bc ;skip "CRX\0"
	ld de,(hl)
	ld c,4
	add hl,bc ;skip "zx7\0" or whatnot
	ex hl,de
	db $01,"zx7" ;ld bc,...
	or a,a
	sbc hl,bc
	jq nz,.fail ;fail if not zx7 compressed
	ex hl,de
	ld bc,(hl) ;load extracted size
	inc hl
	inc hl
	inc hl
	ld de,bos_UserMem
	push bc,hl,de
	call util_Zx7Decompress
	pop de,hl,bc
	push de
	jq .exec_setup_usermem_bc
.jptoprogram:
	ld hl,(running_program_ptr)
	jp (hl)
.normalize_lcd:
	ld bc,ti.vRam
	ld (ti.mpLcdUpbase),bc
	ld a,ti.lcdBpp8
	ld (ti.mpLcdCtrl),a
	xor a,a
	ld (curcol),a
	ret
