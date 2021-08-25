
;@DOES execute a file given a relative or absolute path
;@INPUT int sys_ExecuteFile(const char *path, char *args);
;@OUTPUT -1 and Cf set if file does not exist or is not a valid executable format, or if malloc failed somewhere.
;@OUTPUT ExecutingFileFd set to point to file descriptor. -1 if file not found
;@DESTROYS All, OP6.
;@NOTE If you're running a threaded executable, the thread is spawned but won't actually start until it's thread is handled.
sys_ExecuteFile:
	scf
	sbc hl,hl
	ld (ExecutingFileFd),hl
	xor a,a
	ld (return_code_flags),a
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
	push hl,hl
	call fs_AbsPath
	ld (fsOP6+3),hl
	ex (sp),hl
	call fs_OpenFile ;check if file is found in current working directory
	pop bc
	call c,sys_OpenFileInPath ;call if fs_OpenFile failed to find the file in dirs listed in $PATH
	pop bc ;hl will be result of fs_OpenFile if it didn't fail, otherwise result of sys_OpenFileInPath
	ld bc,(fsOP6+3)
	push hl,af,bc
	call sys_Free ;free the pointer returned by fs_AbsPath
	pop bc,af,hl
	jq c,.fail ;fail if both fs_OpenFile and sys_OpenFileInPath failed to locate the file
.open_fd:
	ld (ExecutingFileFd),hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_subdir,(hl)
	jq nz,.fail ;can't execute a directory
	or a,a
	sbc hl,bc
	push hl
	call fs_GetFDPtr
	pop bc
	ld (running_program_ptr),hl
.exec_check_loop:
	ld a,(hl)
	inc hl
	cp a,$18 ;jr
	jq z,.skip1
	cp a,$C3 ;jp
	jq z,.skip3
	cp a,$EF
	jq nz,.fail ;fail if unrecognized header
	ld a,(hl)
	inc hl
	cp a,$7B
	jq z,.exec_rex_entryhl ;jump if $EF,$7B header
; fail if unrecognized header
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
	db $21, 'TRX' ;ld hl, 'TRX' ;Threaded Ram eXecutable
	or a,a
	sbc hl,de
	jq z,.exec_threaded_rex
	db $21, 'TFX' ;ld hl, 'TFX' ;Threaded Flash eXecutable
	or a,a
	sbc hl,de
	jq z,.exec_threaded_fex
	db $21, 'CRX' ;ld hl, 'CRX' ;Compressed Ram eXecutable
	or a,a
	sbc hl,de
	jq z,.exec_compressed_rex
	db $21, 'FEX' ;ld hl, 'FEX' ;Flash EXecutable
	or a,a
	sbc hl,de
	jq z,.exec_fex
	db $21, 'REX' ;ld hl, 'REX' ;Ram EXecutable
	or a,a
	sbc hl,de
	jq nz,.fail ;if it's neither a Flash Executable nor a Ram Executable, return -1

.exec_rex:
	ld hl,(running_program_ptr)
.exec_rex_entryhl:
	push hl
	ld iy,(ExecutingFileFd)
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
	call sys_FreeRunningProcessId ;free memory allocated by the new process ID
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

.exec_threaded_rex:
	ld hl,(running_program_ptr)
	ld a,(hl)
	cp a,$18
	jq z,.threaded_rex_skipjr
	inc hl
	inc hl
.threaded_rex_skipjr:
	ld de,7 ; length of short jump + length of magic number + length of stack frame chunks indicator
	add hl,de
	ld e,(hl) ; get size of space needed for program
	inc hl
	ld d,(hl)
	inc hl
	push hl,de
	ld a,(running_process_id)
	ld (fsOP6+13),a
	call sys_NextProcessId
	call sys_Malloc
	pop bc
	ex (sp),hl
	push bc
	ld c,(hl) ; get number of entries in relocations table
	inc hl
	ld b,(hl)
	inc hl
	ld (fsOP6+3),hl
	ld (fsOP6+6),bc
	add hl,bc
	add hl,bc ;each entry is 2 bytes. hl should now point to code needing relocation
	pop bc,de
	ld (fsOP6+9),de
	ldir
	ld bc,(fsOP6+6)
	ld a,b
	or a,c
	jq z,.no_relocations
	push iy
	ld iy,(fsOP6+3)
.relocations_loop:
	push bc
	ld c,(iy)
	ld b,(iy+1)
	lea iy,iy+2
	ld hl,(fsOP6+9)
	add hl,bc
	ld bc,(hl)
	ex hl,de
	ld hl,(fsOP6+9)
	add hl,bc
	ex hl,de
	ld (hl),de
	pop bc
	dec bc
	ld a,c
	or a,b
	jq nz,.relocations_loop
	pop iy
.no_relocations:
	ld hl,(running_program_ptr)
	ld de,(fsOP6+9)
	ld (running_program_ptr),de
	jq .exec_threaded_hl
.exec_threaded_fex:
	ld a,(running_process_id)
	ld (fsOP6+13),a
	ld a,1
	ld (running_process_id),a
	ld hl,(running_program_ptr)
.exec_threaded_hl:
	ld a,(hl)
	cp a,$18 ;jr
	jq z,.threaded_skipjr
	inc hl
	inc hl
.threaded_skipjr:
	ld de,6 ;length of short jump + length of magic number
	add hl,de
	ld l,(hl) ;the byte following the magic number should indicate how many 32-byte chunks of stack frame the program requires, minus 1.
	ld h,32
	ld e,h
	mlt hl
	add hl,de ;chunks * 32 + 32
	push hl
	call sys_Malloc
	pop bc
	ret c ;return if failed to malloc

	add hl,bc ;malloc'd pointer + length because the stack grows downwards
	dec hl
	dec hl
	dec hl
	ld de,(running_program_ptr)
	ld (hl),de
	dec hl
	dec hl
	dec hl
	ld bc,.threaded_return_handler ;set program return location so its memory can be easily freed
	ld (hl),bc
	push hl,de
	call th_CreateThread
	ld a,(fsOP6+13)
	ld (running_process_id),a
	ld hl,return_code_flags
	set bSilentReturn,(hl) ;return to caller silently
	pop hl,de
	ret

.threaded_return_handler:
	call sys_FreeRunningProcessId
	call sys_Free ;free the memory the program is allocated in if it's a TRX.
	pop bc
	EndThread ;assume we're still in the program's main thread
