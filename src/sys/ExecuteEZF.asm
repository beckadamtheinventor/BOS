
;@DOES execute an EZF file
;@INPUT int sys_ExecuteEZF(char *path);
;@OUTPUT -1 and Cf set if file does not exist or is not a valid executable format
sys_ExecuteEZF:
	pop bc,hl
	push hl,bc,hl
	call fs_GetFilePtr
	pop de
	ret c
	ld a,c
	or a,b
	jq z,.fail
	ld a,(hl)
	cp a,$7F
	jq nz,.fail
	inc hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	push hl
	db $21,"EZF"
	xor a,a
	sbc hl,de
	pop hl
	jq z,.fail
	or a,b
	jq nz,.atleastminsize
	ld a,c
	cp a,13
	jq c,.fail ;less than minimum size
.atleastminsize:
	push hl
	ex (sp),iy
	push iy
	lea iy,iy+4
.extractloop:
	ld a,(iy)
	inc a
	jq z,.extractloopend
	dec a
	jq z,.next
	jq .extractloop
.extractloopend:
	pop iy
	
	
	
	
	pop iy
.fail:
	scf
	sbc hl,hl
	ret
