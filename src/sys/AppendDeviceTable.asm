
;@DOES add a device to the device table, marking it as open.
;@INPUT device_t** sys_AppendDeviceTable(device_t* ptr);
;@INPUT ptr Pointer to device file.
;@OUTPUT pointer-to-pointer to device file data if success, 0 if device table is full.
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_AppendDeviceTable:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_device_table
	ld b,open_device_table.len / 4
.check_next:
	ld a,(iy)
	or a,a
	jr z,.put_device
	lea iy,iy+4
	djnz .check_next
	sbc hl,hl
	jr .done
.put_device:
	inc a
	ld (iy),a
	ld (iy+1),hl
	lea hl,iy+1
.done:
	pop iy
	ret
