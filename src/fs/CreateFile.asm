;@DOES create a file
;@INPUT bool fs_CreateFile(char *path);
;@DESTROYS All, OP5, OP6
fs_CreateFile:
	pop bc,hl
	push hl,bc
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jr z,.absolute_path
	push hl,hl
	call ti._strlen
	ld (fsOP6+3),hl
	ex (sp),hl
	ld hl,current_working_dir
	push hl
	call ti._strlen
	ld (fsOP6),hl
	ex (sp),hl
	pop bc
	pop hl
	add hl,bc
	push hl
	call sys_Malloc
	pop bc
	ex hl,de
	pop hl
	jq c,.fail
	ld (fsOP6+6),de
	push hl
	ld hl,current_working_dir
	ld bc,(fsOP6+3)
	ldir
	pop hl
	ld bc,(fsOP6)
	ldir
	ld hl,(fsOP6+6)
.absolute_path:
	push hl
	call fs_OpenFile
	pop hl
	jr nc,.fail ;if file exists, don't create new one
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	ld a,'/'
	cpir
	pop de
	jr nz,.create
.fail:
	scf
	sbc hl,hl
	ret
.create:
	ld (fsOP5),de ;char *path
	ld (fsOP5+3),hl ;&path[ last path entry ]
	xor a,a
	sbc hl,de
	ld (fsOP5+6),hl ;last path entry offset from path
	dec hl
	ld (hl),a
	ex hl,de
	push hl
	call fs_OpenFile ;open directory
	pop bc
	jq c,.fail
	ld (fsOP5+9),hl ;void *fd
	push hl
	call sys_EraseSwapSector
	pop hl
	ex.s hl,de
	or a,a
	sbc hl,de
	ex hl,de
	sbc hl,hl
	ld bc,$1000
	push hl,bc,de
	call sys_ToSwapSector
	pop bc,bc,iy
	ld de,1024 shr 2
	add iy,de
	ex hl,de
.copy_cluster_loop:
	
	
	
	ld hl,(fsOP5+9)
	ld bc,$14
	add hl,bc
	ld a,(hl)
	ld c,$1A - $14
	add hl,bc
	ld bc,(hl)
	ld (ScrapMem),bc
	ld (ScrapMem+2),a
	ld bc,(ScrapMem)
	
	ret

