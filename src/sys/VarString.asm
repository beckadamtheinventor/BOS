
;@DOES Similar to sprintf but uses system vars and malloc's the output buffer.
;@INPUT char *sys_VarString(const char *str);
;@OUTPUT hl string where $VAR's are replaced with their respective values. Returns -1 and Cf set if failed.
;@NOTE $VAR must be terminated with a space " " which is not included in the output.
sys_VarString:
	ld hl,-12
	call ti._frameset
	ld (ix-3),iy
	ld hl,string_var_dir
	push hl
	call fs_OpenFile
	pop bc
	ld (ix-6),hl
	ld bc,0
	ld hl,(ix+6)
.len_loop:
	ld a,(hl)
	or a,a
	jq z,.begin_replacing
	inc hl
	inc bc
	cp a,$5C
	jq nz,.len_loop_not_backslash
	inc hl
.len_loop_not_backslash:
	cp a,'$'
	jq nz,.len_loop
	push bc
	ld bc,(ix-6)
	push bc,hl
	call fs_OpenFileInDir
	ex hl,de
	pop hl,bc,bc
	jq c,.bypass_var ;var not found, replace with empty string
	ex hl,de
	push bc
	ld bc,$E
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	pop hl
	add hl,bc
	push hl
	pop bc
	ex hl,de
.bypass_var:
	ld a,(hl)
	or a,a
	jq z,.begin_replacing
	inc hl
	cp a,' '
	jq z,.len_loop
	jq .bypass_var
.begin_replacing:
	push bc
	call sys_Malloc
	jq c,.fail
	ex hl,de
	pop bc
	ld (ix-9),de
	ld hl,(ix+6)
.replace_loop:
	ld a,(hl)
	or a,a
	jq z,.success
	inc hl
	cp a,$5C
	jq nz,.replace_loop_not_backslash
	ld a,(hl)
	inc hl
	cp a,'N'
	jq nz,.maybe_not_newline
.insert_newline:
	ld a,$A
	jq .replace_loop_put_char
.maybe_not_newline:
	cp a,'n'
	jq z,.insert_newline
	cp a,'T'
	jq nz,.maybe_not_tab
.insert_tab:
	ld a,$9
	jq .replace_loop_put_char
.maybe_not_tab:
	cp a,'t'
	jq z,.insert_tab
	jq .replace_loop_put_char
.replace_loop_not_backslash:
	cp a,'$'
	jq z,.replace_var
.replace_loop_put_char:
	ld (de),a
	inc de
	jq .replace_loop
.replace_var:
	ld bc,(ix-6)
	ld (ix-12),de
	push bc,hl
	call fs_OpenFileInDir
	ex hl,de
	pop hl,bc
	jq c,.replace_bypass_var
	push hl ;push input
	ex hl,de ;store fd into hl
	ld bc,$B
	add hl,bc
	ld a,(hl) ;file property byte
	inc hl
	ld de,(hl) ;file sector
	inc hl
	inc hl
	ld c,(hl) ;file len
	inc hl
	ld b,(hl)
	bit fd_subfile,a
	jq z,.regular_file_ptr
	push hl
	ex.s hl,de
	pop de
	ld e,0
	res 0,d
	add hl,de
	jq .replace_copy_file
.regular_file_ptr:
	push bc,de
	call fs_GetSectorAddress
	pop bc,bc
.replace_copy_file:
	ld de,(ix-12) ;restore output pointer
	ldir ;copy var file contents to output
	pop hl
	db $01
.replace_bypass_var:
	ld de,(ix-12) ;3 byte instruction dummified above
.replace_bypass_var_loop:
	ld a,(hl)
	or a,a
	jq z,.success
	inc hl
	cp a,' '
	jq z,.replace_loop
	jq .replace_bypass_var_loop
.success:
	ld (de),a
	ld hl,(ix-9)
	db $01
.fail:
	scf
	sbc hl,hl
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret

.strlen:
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl,bc
	ld a,' '
	cpir
	jq nz,.strlen_returnlen
	pop bc,bc
	scf
	sbc hl,bc
	ret
.strlen_returnlen:
	pop hl,bc
	ret
