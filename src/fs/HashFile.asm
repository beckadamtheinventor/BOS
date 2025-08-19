
;@DOES return the sha256 hash of a file
;@INPUT bool fs_HashFile(void *fd, uint8_t *hash);
;@OUTPUT returns true if success, false and Cf set if the file descriptor is invalid or empty.
;@NOTE hash must be allocated at least 32 bytes.
fs_HashFile:
	call ti._frameset0
	ld hl,(ix+6) ; void* fd
	call fs_GetFilePtr.entryfd ; returns data pointer in hl, size in bc
	jr c,.fail
	ld de,(ix+9) ; uint8_t* hash
	push bc,hl,de ; len, data, buffer
	call util_SHA256
	pop bc,bc,bc
	scf
.fail:
	ccf
	sbc a,a
	pop ix
	ret
