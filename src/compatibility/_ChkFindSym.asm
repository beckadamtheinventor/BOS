;@DOES Search for a file (no extension) in the "/bin/" directory
;@INPUT OP1+1 8 byte file name
;@OUTPUT HL = pointer to 2 byte file length
;@OUTPUT DE = pointer to file data
;@OUTPUT Cf set if file not found or otherwise cannot be opened.
;@DESTROYS OP1
_ChkFindSym:
	ld hl,fsOP1+9
	ld de,fsOP1+9+.str_bin_len
	ld bc,9
	lddr
	ld de,fsOP1
	push de
	ld c,.str_bin_len ;bc is already zero
	ldir
	call fs_OpenFile
	pop bc
	ret c

	ld bc,fsentry_filesector ;file pointer
	add hl,bc
	ld bc,(hl)
	push hl,bc
	call fs_GetSectorAddress
	ex hl,de
	pop bc,hl
	ld bc,fsentry_filesector - fsentry_filelen
	add hl,bc
	ret
.str_bin:
	db "/bin/"
.str_bin_len:=$-.str_bin
