;@DOES Initialize a device (if needed)
;@INPUT int drv_InitDevice(device_t* ptr);
;@INPUT ptr Pointer to device file.
;@OUTPUT depends on device, usually -1 and Cf set if failed.
drv_InitDevice:
	pop bc,hl
	push hl,bc
.entryhl:
	ld a,(hl)
	cp a,$C9
	jr nz,.fail
	push hl
	call sys_SearchDeviceTable.entryhl
	pop de
	ret nz ; don't reinit an already initialized device
	ex hl,de
	call sys_AppendDeviceTable.entryhl
	ret z
	ld hl,(hl)
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

