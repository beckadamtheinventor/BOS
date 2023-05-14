
;@DOES Initialize a device (if needed) and return a device structure.
;@INPUT device_t *sys_OpenDevice(const char *name);
;@OUTPUT pointer to device structure. (file data)
;@OUTPUT hl=-1 and Cf set if failed.
sys_OpenDevice:
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
	ld a,(hl)
	cp a,$C9
	jr nz,.fail
	call sys_SearchDeviceTable.entryhl
	ret nz ; don't reinit an already initialized device
	call sys_AppendDeviceTable.entryhl
	ret z
	push hl
	inc hl
	bit bDeviceNeedsInit,(hl)
	ld bc,6
	add hl,bc
	call nz,sys_jphl
	pop hl
	ret
.fail:
	scf
	sbc hl,hl
	ret

