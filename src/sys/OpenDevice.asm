
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
	ld a,(hl)
	cp a,$C9
	jr nz,.fail
	push bc
	call sys_SearchDeviceTable.entryhl
	pop bc
	ret nz ; don't reinit an already initialized device
	push bc
	call sys_AppendDeviceTable.entryhl
	pop bc
	ret z
	push hl
	inc hl
	bit bDeviceNeedsInit,(hl)
	jr z,.noneedinit
	inc hl
	inc hl
	inc hl
	call sys_jphl
.noneedinit:
	pop hl
	ret
.fail:
	scf
	sbc hl,hl
	ret

