
;@DOES delete a file given a file name
;@INPUT bool fs_DeleteFile(const char *name);
;@OUTPUT true if success, otherwise fail
fs_DeleteFile:
	ld hl,-12
	call ti._frameset

; open the file to be deleted and check if it's writable
	ld hl,(ix+6)
	push hl
	call fs_CheckWritable
	dec a
	jq nz,.fail
	call fs_OpenFile
	pop bc
;	jq c,.fail
	ld (ix-3),hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fsbit_readonly,(hl)
	jq nz,.fail

; grab parent dir's file descriptor, data pointer, and data length
	ld bc,(ix+6)
	push bc
	call fs_ParentDir
	ex (sp),hl
	call fs_OpenFile
	pop bc
	ld (ix-6),hl
	ld bc,$C
	add hl,bc
	ld de,(hl)
	push de
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld (ix-12),bc
	call fs_GetSectorAddress
	pop bc
	ld (ix-9),hl

;free the file's data
	ld hl,(ix-3) ;free deleted file's data section
	push hl
	call fs_Free
	pop bc

; overwrite the file descriptor
	ld bc,(ix-12)
	ld hl,(ix-9)
	add hl,bc
	ld bc,(ix-3)  ;get offset of file's descriptor to delete from end of parent directory file
	or a,a
	sbc hl,bc ;hl is end of directory - file descriptor
	push hl ;hl is number of bytes to copy down
	ld bc,(ix-3)
	ld hl,16
	add hl,bc ;copy down from next file descriptor to delete this one
	push hl,bc
	call sys_WriteFlashFullRam

; resize parent directory down 16 bytes to account for deleted entry
	ld bc,(ix-12)
	ld hl,-16
	add hl,bc
	ld bc,(ix-6)
	push bc,hl
	call fs_SetSize ;resize parent dir down 16 bytes
	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	ld sp,ix
	pop ix
	ret

