;@DOES (TODO) Create a var in the /var directory and return a pointer to it
;@INPUT void *sys_CreateVar(varstruct_t *var);
;@OUTPUT hl pointer to var data, or Cf set and hl = -1 if failed
;@NOTE This routine expects var to be persistent if it is a pointer type
sys_CreateVar:
	ld hl,-8
	call ti._frameset
	ld de,str_var_index_name
	push hl,de
	call fs_GetFilePtr
	pop bc
	jq nc,.found_index
	pop de
	ld de,1024
	push de,de,bc
	call fs_CreateFile
	pop bc,bc,bc
	jq nc,.
	jq .fail
.found_index:
	ld de,8
	ld b,d
.index_loop:
	ld a,(hl)
	inc a
	jq z,.found_free
	add hl,de
	djnz .index_loop
	pop de
.fail:
	scf
	sbc hl,hl
.success:
	ld sp,ix
	pop ix
	ret
.found_free:
	ex hl,de
	ld bc,8
	push bc
	pea ix-8
	push de
	ld hl,(ix+6)
	ld a,(hl)
	bit 7,a
	ld (ix-8),a
	jq z,.non_pointer_type
	ld (ix-7),hl
	inc hl
	ld d,b
	ld e,b
	ld bc,(hl)
	ld (ix-4),c
	ld (ix-3),b
	inc hl
.count_loop:
	inc hl
	ld a,e
	add a,(hl)
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	dec bc
	ld a,c
	or a,b
	jq nz,.count_loop
	ld (ix-2),e
	ld (ix-1),d
	jq .write_var
.non_pointer_type:
	inc hl
	ld c,(hl)
	inc hl
	ld de,(hl)
	ld (ix-4),c
	ld (ix-3),de
	dec b
	ld (ix-7),b
	ld (ix-6),b
	ld (ix-5),b
.write_var:
	call sys_WriteFlashFullRam
	pop bc,bc,bc
	jq .success
