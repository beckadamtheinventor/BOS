
sc_LoadSysCall:
	ld hl,-9
	call ti._frameset
	lea de,ix-9
	ld hl,(ix+6)
	ld c,8
.copy_dir_loop:
	ldi
	jp po,.done_copying_dir
	ld a,(hl)
	cp a,'/'
	jr nz,.copy_dir_loop
	jr z,.done_passing_filename
.done_copying_dir:
	ld a,(hl)
	cp a,'/'
	inc hl
	jr nz,.done_copying_dir
	dec hl
.done_passing_filename:
	inc hl
	ld (ix+6),hl ; advance routine name past library name
	xor a,a
	ld (de),a
	lea hl,ix-9
	ld de,str_SysCallsVar
	push de,hl
	call sys_OpenFileInVar
	pop de,de
	jp c,.fail_cf
	push hl
	call fs_GetFDLen
	ex (sp),hl
	push hl
	call fs_GetFDPtr
	pop bc,bc
	ld (ix-3),hl
	push bc
	ex (sp),hl
	ld bc,10 ; minimum file size
	sbc hl,bc
	add hl,bc
	ex (sp),hl
	pop bc
	jr c,.fail_cf
	ld de,.fail
	push de ; push error return so we can "ret po" instead of "jp po"
	dec bc
	dec bc
	dec bc
	dec bc
	dec bc
; check file header "SCL",0
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	inc hl
	or a,a
	ret nz
	push hl
	db $21,"SCL"
	sbc hl,de
	pop hl
	ret nz
.search_loop:
	ld de,(ix+6)
	cpi
	ret po
	cpi
	ret po
	push bc,hl,de
	call ti._strcmp
	add hl,bc
	or a,a
	sbc hl,bc
	pop de,hl,bc
	jr z,.found
.next:
	xor a,a
	cpir
	ret po
	cpi
	ret po
	ret z ; if next entry starts with a null byte, we've reached the end of the file
	jr .search_loop
.found:
	ld (ix-6),hl
	mlt de ; zero deu
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ld a,(hl)
	ld hl,(ix-3)
	add hl,de
	pop bc ; pop error return
	dec a
	jr z,.success ; if type==1, run routine in-place
	dec a
	jr z,.ram_routine ; if type==2, copy routine to ram first
	dec a
	jr nz,.fail ; fail if unknown routine type
; if type==3, return data
	mlt bc ; zero bcu
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	jr .success
.ram_routine:
	mlt bc ; set bcu to 0
	ld c,(hl) ; routine length
	inc hl
	ld b,(hl)
	inc hl
	ld de,(hl) ; ram location routine will run at
	inc hl
	inc hl
	inc hl
	push de
	ldir ; copy the routine to ram at a given static location
	pop hl
.success:
	db $01 ; dummify following scf / sbc hl,hl
.fail:
	scf
.fail_cf:
	sbc hl,hl
.done:
	ld sp,ix
	pop ix
	ret
