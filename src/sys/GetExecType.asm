
;@DOES Check the executable type of a given file
;@INPUT const char *sys_GetExecType(const char *path);
;@OUTPUT pointer to executable magic bytes, or -1 and Cf set if failed.
;@NOTE returns pointer to executable code in de and length of executable code in bc if hl != -1
sys_GetExecType:
	pop bc,hl
	push hl,bc
.entry:
	call fs_GetFilePtr.entryname
	ret c
.entryhlbc:
	push bc
	ex (sp),hl
	ld bc,3
	or a,a
	sbc hl,bc
	add hl,bc
	ex (sp),hl
	pop bc
	jr nc,.over_min_size
.fail_early:
	scf
.fail_early_cf:
	sbc hl,hl
	ret
.over_min_size:
	ld a,(hl)
	cp a,'#'
	jr nz,.not_executable_text
	inc hl
	ld a,(hl)
	cp a,'!'
	jr nz,.fail_early_cf
	dec hl
	ld a,$0A
	push hl
	cpir
	ex hl,de
	pop hl
	ret ; return hl = start of file, de = next line following start of file, or the end of the file, bc = remaining length of file.
.not_executable_text:
	ld a,(hl)
	cp a,$EF
	jr nz,.not_ef7b
	push hl
	inc hl
	ld a,(hl)
	inc hl
	ex (sp),hl
	pop de
	cp a,$7B
	dec bc ; adjust length for header
	dec bc
	ret z ; return if header is 0xEF,0x7B
	inc bc
	inc bc
.not_ef7b:
	push bc
	ex (sp),hl
	ld bc,13
	or a,a
	sbc hl,bc
	add hl,bc
	ex (sp),hl
	pop bc
	push hl,bc
	jr c,.not_arc_header
	ld bc,9
	add hl,bc
	ld c,(hl)
	add hl,bc
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	cp a,$EF
	jr nz,.not_arc_header
	inc hl
	ld a,(hl)
	dec hl
	cp a,$7B
	jr nz,.not_arc_header
	ex (sp),hl
	or a,a
	sbc hl,bc
	ld c,14
	sbc hl,bc  ; hl = filelen - (9 + fileptr[9] + 1 + 2 + 2)
	ex (sp),hl
	pop bc,de
	push hl
	pop de
	inc de ; return de = &fileptr[14 + fileptr[9]] as the executable code
	inc de
	ret ; return hl = &fileptr[12 + fileptr[9]] as the executable header
.not_arc_header:
	pop bc,de
	push de
	pop hl
	ld a,(hl)
	inc hl
	inc hl
	cp a,$18 ; jr byte
	ret z ; return &fileptr[2] as the executable header
	inc hl
	inc hl
	cp a,$C3 ; jp byte
	ret z ; return &fileptr[4] as the executable header

	ld b,0    ; try interpreting it as a tivar
	ld c,(hl)
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld a,(hl)
	cp a,$EF
	jr nz,.fail ; fail if it's not a TI formatted 0xEF,0x7B executable
	inc hl
	ld a,(hl)
	dec hl
	cp a,$7B
	jr nz,.fail ; fail if it's not a TI formatted 0xEF,0x7B executable
	push hl
	pop de
	dec bc ; adjust length for header
	dec bc
	inc de
	inc de
	ret

.fail:
	scf
.ret_cf:
	sbc hl,hl
	ret

