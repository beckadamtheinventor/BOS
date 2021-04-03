;@DOES convert a file.ext string to a file entry
;@INPUT char *fs_StrToFileEntry(char *dest, const char *src);
;@OUTPUT pointer to file entry, 0 if failed
;@OUTPUT Cf set if failed
fs_StrToFileEntry:
	pop bc,de,hl
	push hl,de,bc
	ld a,(hl)
	or a,a
	jq nz,.main
	xor a,a
	sbc hl,hl
	scf
	ret
.main:
	push de
	ld b,8
.copy_file_name_loop:
	ld a,(hl)
	or a,a
	ld c,a
	jq z,.pad_file_name
	inc hl
	cp a,'.'
	jq z,.pad_file_name
	ld (de),a
	inc de
	djnz .copy_file_name_loop
	ld c,(hl)
	inc hl
	jq .copy_file_name_ext
.pad_file_name:
	ld a,' '
.pad_file_name_loop:
	ld (de),a
	inc de
	djnz .pad_file_name_loop
.copy_file_name_ext:
	ld b,3
	ld a,c
	or a,a
	jq z,.pad_file_ext
.copy_file_name_ext_loop:
	ld a,(hl)
	or a,a
	jq z,.pad_file_ext
	inc hl
	ld (de),a
	inc de
	djnz .copy_file_name_ext_loop
	jq .finished_copying_name
.pad_file_ext:
	ld a,' '
.pad_file_ext_loop:
	ld (de),a
	inc de
	djnz .pad_file_ext_loop
	ld a,(hl)
	or a,a
	jq nz,.fail
.finished_copying_name:
	pop hl
	or a,a
	ret
.fail:
	pop bc
	scf
	sbc hl,hl
	ret


