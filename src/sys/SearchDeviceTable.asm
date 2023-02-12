
;@DOES check if a device (by file descriptor) is open or not
;@INPUT bool sys_SearchDeviceTable(void *fd);
;@OUTPUT true if device is open, false otherwise
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_SearchDeviceTable:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_device_table
.check_next:
	lea iy,iy+4
	ld a,(iy-4)
	or a,a
	jr z,.device_closed
	ld de,(iy-3)
	sbc hl,de
	add hl,de
	jr nz,.check_next
	dec a
	jr nz,.device_closed
.device_open:
	db $F6 ; or a,... dummify xor a
.device_closed:
	xor a,a
	pop iy
	ret
