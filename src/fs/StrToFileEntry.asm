;@DOES convert a file.ext string to a file entry
;@INPUT char *fs_StrToFileEntry(char *dest, const char *src);
;@OUTPUT pointer to file entry, 0 if failed. First byte of file entry will be fsentry_longfilename if file's name is too long for an 8.3 path.
;@OUTPUT Cf set if failed
fs_StrToFileEntry:
	pop bc,de,hl
	push hl,de,bc
	ld a,(hl)
	or a,a
	jr z,.__fail
.main:
	push de,hl
	ld b,8
.checkpathnameloop:
	ld a,(hl)
	inc hl
	or a,a
	jr z,.notlongfilename
	cp a,'.'
	jr z,.checkpathext
	djnz .checkpathnameloop
	ld a,(hl)
	or a,a
	jr z,.notlongfilename
	cp a,'.'
	jr nz,._fail
.checkpathext:
	ld b,3
	ld a,(hl)
	inc hl
	or a,a
	jr z,.notlongfilename
	djnz .checkpathext
	ld a,(hl)
	or a,a
	jr z,.notlongfilename
._fail:
	pop hl,hl
.__fail:
	sbc hl,hl
	scf
	ret
; .definitelylongfilename:
	; pop hl,hl
	; ld (hl),fsentry_longfilename
	; or a,a
	; sbc hl,hl
	; scf
	; ret
.notlongfilename:
	pop hl
	ld b,8
.copy_file_name_loop:
	ld a,(hl)
	or a,a
	ld c,a
	jq z,.pad_file_name
	cp a,' '
	jq z,.pad_file_name_loop
	inc hl
	cp a,'.'
	jq z,.pad_file_name
	ld (de),a
	inc de
	djnz .copy_file_name_loop
	ld c,(hl)
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
	cp a,' '
	jq z,.pad_file_ext_loop
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
