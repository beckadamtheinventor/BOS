
;@DOES add a device to the device table, marking it as open.
;@INPUT bool sys_AppendDeviceTable(void *fd);
;@OUTPUT true if success, false if device table is full.
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_AppendDeviceTable:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_device_table
	ld b,open_device_table.len / 4 - 1
.check_next:
	ld a,(iy)
	or a,a
	jr z,.put_device
	dec a
	jr nz,.put_device_xor_a
	lea iy,iy+4
	djnz .check_next
	xor a,a
	jr .done
.put_device_xor_a:
	xor a,a
.put_device:
	inc a
	ld (iy),a
	ld (iy+1),hl
.done:
	pop iy
	ret
