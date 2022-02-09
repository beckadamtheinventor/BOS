
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
	xor a,a
	ld bc,fsentry_fileattr
	add hl,bc
	bit fsbit_readonly,(hl)
	jr nz,.fail
	scf
.fail:
	adc a,a
	ret
