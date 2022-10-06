;@DOES Build the VAT from variables found in tivars.
_BuildVAT:
	ld hl,-3
	call ti._frameset
	ld hl,str_var_tivars
	push hl
	call fs_GetFilePtr
	pop de
	jp c,.done
	ex hl,de
.dir_loop:
	push bc,de

	ld bc,0
.build_vat_loop:
	push bc,de
	call os_check_recovery_key
	pop de
	ld bc,1
	push bc,de
	pea ix-3
	call fs_DirList
	pop iy,de,bc,bc
	jr c,.dir_doesnt_exist
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.dir_doesnt_exist
	inc bc
	push bc,de
	ld hl,(iy)
	push hl
	call fs_CopyFileName
	push hl
	xor a,a
	ld de,ti.OP1
	ld (de),a
	inc de
.copy_file_name_loop:
	ldi
	ld a,(hl)
	or a,a
	jr nz,.not_done_copying_file_name
	ld (de),a
	jr .done_copying_file_name
.not_done_copying_file_name:
	cp a,'.'
	jr nz,.copy_file_name_loop
	xor a,a
	ld (de),a
	inc hl
	ld a,(hl)
	cp a,'v'
	jr nz,.file_not_a_var
	inc hl
	call .nibble
	add a,a
	add a,a
	add a,a
	add a,a
	ld c,a
	call .nibble
	add a,c
	ld (ti.OP1),a
.done_copying_file_name:
	call sys_Free
	pop hl,bc
	ld hl,(iy)
	call fs_GetFDPtr.entry
	push hl
	ld hl,(iy)
	call fs_GetFDLen.entry
	ld c,l
	ld b,h
	pop hl
	call _AddVATEntry
	jr .next_file
.file_not_a_var:
	call sys_Free
	pop hl,bc
.next_file:
	pop de,bc
	jq .build_vat_loop
.dir_doesnt_exist:
	pop hl,bc
	ld a,':' ; find next ':' character in /var/TIVARS. If none found, we're done looking for files.
	cpir
	ex hl,de
	jp pe,.dir_loop
	xor a,a
.done:
	ld sp,ix
	pop ix
	ret

.nibble:
	ld a,(hl)
	inc hl
	sub a,'0'
	cp a,10
	ret c
	sub a,'A'-'9'+1
	ret
	