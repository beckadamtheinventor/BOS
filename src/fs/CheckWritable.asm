
;@DOES Check if a file can be written to.
;@INPUT uint8_t fs_CheckWritable(const char *path);
;@OUTPUT 0 if file cannot be written to, -1 and Cf set if file doesn't exist, 1 if the file can be written to.
;@NOTE takes into consideration whether the OS is in "elevated" mode
fs_CheckWritable:
	pop bc,hl
	push hl,bc,hl
	call fs_OpenFile
	pop bc
	ld a,l
	ret c
.entry:
	ld bc,$B
	add hl,bc
	bit fsbit_readonly,(hl)
	jq z,.success
;if the readonly flag is set, check whether we're in elevated mode
	call fs_GetElevationFile
	ld a,c
	or a,b
	ret z
.searchloop:
	ld a,(hl)
	or a,a
	jq nz,.foundid
	inc hl
	dec bc
	ld a,b
	or a,c
	jq nz,.searchloop
.foundid:
	cp a,$5A
	jq z,.success ;if we're in elevated mode, all files are writable
	xor a,a
	ret
.success:
	xor a,a
	inc a
	ret
