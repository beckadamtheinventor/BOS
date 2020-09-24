;@DOES check if a directory exists.
;@INPUT bool fs_CheckDirExists(char *path);
;@OUTPUT zf/a=0 if path exists, else nzf/cf/a!=0.
;@NOTE uses InputBuffer and fsOP6
fs_CheckDirExists:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	inc hl
	ld a,(hl)
	cp a,':'
	jr z,.abspath
	ld hl,current_working_dir
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld de,InputBuffer
	ldir
	ex hl,de
	ld (hl),'/'
	inc hl
	push hl
	call ti._strcpy
	pop bc,bc
	ld hl,InputBuffer
	jr .next
.abspath:
	ld hl,InputBuffer
	push hl
	call ti._strcpy
	pop hl,bc
.next:
	ld a,(hl)
	inc hl
	push hl
	call fs_RootDir
	pop de
	jq c,.fail
	push hl
	ld bc,$14
	add hl,bc
	ld a,(hl)
	ld c,$1A - $14
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld (ScrapMem),bc
	ld (ScrapMem+2),a
	ld hl,(ScrapMem)
	ld b,10
.cluster_mult_loop:
	add hl,hl
	djnz .cluster_mult_loop
	pop bc
	ld c,0 ;bc &= $FFF800
	res 0,b
	add hl,bc ;add sector address of data section
	push ix
	push hl
	pop ix
	or a,a
	ld hl,InputBuffer
	ld (fsOP6),hl
.search_loop:
	ld a,(ix)
	or a,a
	jr z,.fail_popix ;reached end of directory
	ld bc,fsOP6+3
	push ix,bc
	call fs_CopyFileName ;get file name string from file entry
	pop hl,bc
	push hl
	call ti._strlen ;get length of file name string from file entry
	ex (sp),hl
	ld bc,(fsOP6)
	push bc
	push hl
	call ti._strncmp ;compare with the target directory
	pop bc,de
	or a,a
	jr z,.into_dir
.search_next:
	lea ix,ix+32
	jr .search_loop
.into_dir:
	ld hl,(fsOP6)
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,'/'
	cpir
	jr nz,.return ;directory exists \o/
	inc hl
	ld (fsOP6),hl ;advance path entry
	ld hl,(ix+$12) ;load byte at ix+$14 into hl upper byte
	ld l,(ix+$1A) ;load low two bytes
	ld h,(ix+$1B)
	ld b,10
.cluster_mult_loop2:
	add hl,hl
	djnz .cluster_mult_loop2
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail_popix ;uninitialized probably bad dir entry
	push hl
	pop ix
	jr .search_loop
.fail_popix:
	pop ix
.fail:
	scf
	sbc a,a
	ret
.return:
	pop ix
	xor a,a
	ret
