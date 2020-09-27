
;@DOES execute a file from a given entry point
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
	ld a,(hl)
	or a,a
	jq z,.fail
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jq nz,.open_system_exe
	push de
.try_open:
	push hl
	call fs_OpenFile
	jr c,.try_exe
.open_fd:
	ld (fsOP6),hl ;save file descriptor for later
	ld bc,$B
	add hl,bc
	bit 4,(hl)
	ld hl,(fsOP6)
	pop bc
	jr nz,.fail_popbc
	ld bc,0
	push bc
	push hl
	call fs_GetSectorPtr
	pop bc,bc
	jq c,.fail_popbc
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
	push de
	push hl
	call ti._strlen
	push hl
	ld bc,3
	add hl,bc
	push hl
	call sys_Malloc
	ld (fsOP6),hl
	ex hl,de
	pop bc
	ld bc,3
	ld hl,.system_drive_prefix
	ldir
	pop bc
	pop hl
	ldir
	ld hl,(fsOP6)
	jq .try_open
.try_exe:
	call ti._strlen
	ld bc,11
	or a,a
	sbc hl,bc
	jq nc,.fail_popbc
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
	call fs_OpenFile
	jq c,.fail_pop2bc
	jq .open_fd
.ext:
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
	ld hl,(fsOP6) ;file descriptor
	ld bc,$1C   ;offset of file length
	add hl,bc
	ld bc,(hl)  ;get file length in bytes
	pop hl      ;file data pointer
	ld de,bos_UserMem
	push de
	ldir
	pop hl ;usermem
	ex (sp),hl ;save usermem, restore args
	ret ;jump to usermem
.exec_fex:
	pop hl
	ex (sp),hl
	ret
