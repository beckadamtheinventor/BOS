
fs_ExtractOSOptBinaries:
	ld ix,fs_root_file_initializers
.entryix:
	ld hl,str_ExtractingFiles
	call gui_PrintLine
	ld hl,current_working_dir
	ld (hl),'/'
	inc hl
	ld (hl),0
.loop:
	ld a,(ix+1)
	ld c,(ix)
	or a,c
	ret z ; return if no more files/directories to initialize
	bit fd_subdir,c
	jq z,.extract_file
.extract_dir:
	push bc
	pea ix+1
	call fs_CreateDir
	call ti._strlen
	pop bc
	add hl,bc
	inc hl
	ex (sp),hl
	pop ix
	jq .loop
.extract_file:
	ld a,'/'
	call gui_PrintChar
	lea hl,ix+1
	push hl
	call gui_PrintLine
	call ti._strlen
	pop bc
	add hl,bc
	inc hl
	ld de,(hl) ; grab file uncompressed length
	inc hl
	inc hl
	push hl,de
	ld c,(ix)
	push bc
	pea ix+1
	call fs_DeleteFile ; delete the old file
	call fs_CreateFile ; create and allocate the file
	jq c,.skip_file ; dont try to write if we failed to create the file
	push hl
	call fs_GetFDPtr ; get pointer to the data section
	ex hl,de
	pop bc,bc,bc,bc,hl
	ld c,e ; directory low byte will always be zero
	mlt bc ; set bc to zero
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push bc,hl,de
	call sys_FlashUnlock
	call util_Zx7DecompressToFlash
	call sys_FlashLock
.skip_file:
	pop bc,hl,bc
	add hl,bc
	push hl
	pop ix
	jq .loop
