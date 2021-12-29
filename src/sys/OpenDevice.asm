
;@DOES Initialize a device and return a device structure.
;@INPUT device_t *sys_OpenDevice(const char *name);
;@OUTPUT pointer to device structure. (file data)
;@OUTPUT hl=-1 and Cf set if failed.
sys_OpenDevice:
	pop bc,hl
	push hl,bc,hl
	call fs_OpenFile
	pop bc
	ret c
	push hl
	call fs_GetFDPtr
	pop bc
	ld a,(hl)
	cp a,$C9
	jr nz,.fail
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


