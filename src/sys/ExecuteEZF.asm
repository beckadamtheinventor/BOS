
;@DOES execute an EZF file
;@INPUT int sys_ExecuteEZF(const char *path);
;@OUTPUT -1 and Cf set if file does not exist or is invalid or is malformed
;@NOTE TODO/TBD
sys_ExecuteEZF:
	pop bc
	ex (sp),hl
	push bc
	push hl
	call fs_GetFilePtr
	pop de
	ret c
	jr .loadfromptr
.loadfromfd:
	push hl
	call fs_GetFDLen
	ex (sp),hl
	push hl
	call fs_GetFDPtr
	pop bc,bc
.loadfromptr:
	ld a,c
	or a,b
	jr z,.fail
	ld a,(hl)
	cp a,$7F
	jr nz,.fail
	inc hl
	ld de,(hl)
	push hl
	db $21,"EZF"
	xor a,a
	sbc hl,de
	pop hl
	jr z,.fail
	or a,b
	jr nz,.atleastminsize
	ld a,c
	cp a,13
	jr nc,.atleastminsize
;less than minimum size
.fail:
	scf
	sbc hl,hl
	ret
.fail_popiy:
	pop iy
	jr .fail
.atleastminsize:
	dec hl
	push hl
	ex (sp),iy
	lea iy,iy-4
	ld (fsOP1),iy
.dependency_loop:
	lea iy,iy+8
	ld a,(iy)
	inc a
	jr z,.start_load_loop
	dec a
	jr z,.dependency_loop
	cp a,ezsec.extern
	jr nz,.dependency_loop
	
	jr .dependency_loop
.start_load_loop:
	ld iy,(fsOP1)
.load_loop:
	lea iy,iy+8
	ld a,(iy)
	inc a
	jr z,.start_relocating
	dec a
	jr z,.load_loop
	sub a,ezsec.rodat
	jr c,.load_loop
	
	
	jr .load_loop
.start_relocating:
	


