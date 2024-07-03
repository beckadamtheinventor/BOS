;@DOES Initialize a device (if needed)
;@INPUT int drv_InitDevice(const char *name);
;@OUTPUT depends on device, usually -1 and Cf set if failed.
drv_InitDevice:
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
assert device_Flags = 1
	inc hl
	bit bDeviceNeedsInit,(hl)
	ret z
	ld bc,device_JumpInit - 1
	jr drv.common_no_args
.fail:
	scf
	sbc hl,hl
	ret

