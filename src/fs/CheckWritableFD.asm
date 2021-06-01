
;@DOES Check if a file descriptor is writable.
;@INPUT uint8_t fs_CheckWritableFD(void *fd);
fs_CheckWritableFD:
	pop bc,hl
	push hl,bc
	jq fs_CheckWritable.entry
