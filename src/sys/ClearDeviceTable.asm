;@DOES Clear all devices from the device table, calling deinit if needed.
;@INPUT void sys_ClearDeviceTable();
;@INPUT ptr Pointer to device file.
;@OUTPUT pointer-to-pointer to device file data if success, 0 if device table is full.
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_ClearDeviceTable:
	push iy
	ld iy,open_device_table-4
	ld b,open_device_table.len / 4
.loop:
	lea iy,iy+4
	ld a,(iy)
	or a,a
	jr nz,.close_dev
.next:
	djnz .loop
	pop iy
	ret
.close_dev:
	push iy,bc
	ld de,(iy+1)
	sbc hl,hl
	ld (iy),l
	ld (iy+1),hl
	ex hl,de
	call drv_DeinitDevice.entryhl
	pop bc,iy
	jr .next
