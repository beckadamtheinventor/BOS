;@DOES Clear all devices from the device table, calling deinit if needed.
;@INPUT void sys_ClearDeviceTable();
;@INPUT ptr Pointer to device file.
;@OUTPUT pointer-to-pointer to device file data if success, 0 if device table is full.
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_ClearDeviceTable:
	push iy
	ld iy,open_device_table
	ld b,open_device_table.len / 4 - 1
.loop:
	ld a,(iy)
	or a,a
	jr nz,.close_dev
	lea iy,iy+4
	djnz .loop
	pop iy
	ret
.close_dev:
	push iy
	ld hl,(iy+1)
	call drv_DeinitDevice.entryhl
	pop iy
	jr .loop
