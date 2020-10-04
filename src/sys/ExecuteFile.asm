
;@DOES execute a file
;@INPUT int sys_ExecuteFile(char *path, char *args);
;@OUTPUT -1 if file does not exist or is not a valid executable format
;@DESTROYS All, OP5, and OP6.
sys_ExecuteFile:
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
	push hl,de
	call sys_PushArgumentStack
	pop de,hl
	ld a,(hl)
	or a,a
	jq z,.fail
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	push hl
	jq nz,.open_system_exe
	call fs_OpenFile
	jr c,.try_exe
.open_fd:
	ld (fsOP6),hl ;save file descriptor for later
	ld bc,$B
	add hl,bc
	bit 4,(hl)
	ld hl,(fsOP6)
	pop bc
	jr nz,.fail
	ld bc,0
	push bc
	push hl
	call fs_GetClusterPtr
	pop bc,bc
	jq c,.fail
	push hl
	ld a,(hl)
	cp a,$18 ;jr
	jr z,.skip2
	cp a,$C3 ;jp
	jr z,.skip4
.fail_pop2bc:
	pop bc
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
	jq .ext
.system_drive_prefix:
	db "A:/",0
.open_system_exe:
	call ti._strlen
	push hl
	ld bc,4+5
	add hl,bc
	push hl
	call sys_Malloc
	pop bc
	jq c,.fail_pop2bc
	ld (fsOP6),hl
	ex hl,de
	ld bc,3
	ld hl,.system_drive_prefix
	ldir
	pop bc
	pop hl
	ldir
	ld hl,str_dotEXE
	ld bc,5
	ldir
	ld hl,(fsOP6)
	push hl
	jq .try_open
.try_exe:
	call ti._strlen
	ld bc,11
	or a,a
	sbc hl,bc
	jq nc,.fail
	ld de,fsOP5
	push de
	call ti._strcpy
	pop hl,bc
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	add hl,bc
	ex hl,de
	ld hl,str_dotEXE
	ld bc,5
	ldir
.try_open:
	call fs_OpenFile
	jq c,.fail_popbc
	jq .open_fd
.ext:
	ld a,(hl)
	cp a,$EF
	jq z,.check_ef7b
	ld de,(hl)
	db $21 ;ld hl,...
	db 'FEX' ;Flash EXecutable
	or a,a
	sbc hl,de
	jr z,.exec_fex
	db $21 ;ld hl,...
	db 'REX' ;Ram EXecutable
	or a,a
	sbc hl,de

	jq nz,.fail_popbc ;if it's neither a Flash Executable nor a Ram Executable, return -1

	or a,a
	sbc hl,hl
	ld (fsOP6+3),hl

.exec_rex:
	pop hl      ;file data pointer (not needed, this is re-handled in fs_Read)
	ld hl,(fsOP6) ;file descriptor
	push hl     ;void *fd
	ld bc,$1C   ;offset of file length
	add hl,bc
	ld bc,(hl)  ;get file length in bytes
	ld (asm_prgm_size),bc
	ld hl,(fsOP6+3)
	ex (sp),hl  ;int offset
	push hl     ;void *fd
	ld e,1
	push de     ;uint8_t count
	push bc     ;int len
	ld de,bos_UserMem
	push de ;void *dest
	ex hl,de
	add hl,bc
	ld (top_of_UserMem),hl
	call fs_Read
	pop de,bc,bc,bc,bc
	jq c,.fail
	push de ;jump address
	xor a,a
	ld (console_line),a
	ld (console_col),a
.exec_fex:
	call sys_GetArgumentStack ;get arguments
	ex (sp),hl ;push arguments to stack, pop jump location from the stack
.run_hl:
	call .jphl
	pop bc
	push hl
	call sys_PopArgumentStack
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	pop hl
	ret
.jphl:
	ld (SaveSP),sp
	di
	jp (hl)

.check_ef7b:
	inc hl
	ld a,(hl)
	cp a,$7B
	jq nz,.fail_popbc
	ld hl,2
	ld (fsOP6+3),hl
	jq .exec_rex
	


