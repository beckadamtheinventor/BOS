;@DOES Return a pointer to a device structure (if valid)
;@INPUT device_t* drv_OpenDevice(const char *path);
;@INPUT path Path of device file to open.
;@OUTPUT pointer to device structure, -1 and Cf set if failed.
drv_OpenDevice:
	pop bc,hl
	push hl,bc
.entryhl:
	push hl
	call fs_OpenFile
	pop bc
	ret c
	push hl
	call fs_GetFDPtrRaw.entry
	pop bc
	ret c
.entryfd:
	ld a,(hl)
	cp a,$C9
	ret z
	scf
	sbc hl,hl
	ret
