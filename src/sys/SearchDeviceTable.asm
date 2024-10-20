;@DOES check if a device (by data pointer) is open or not
;@INPUT device_t** sys_SearchDeviceTable(device_t* ptr);
;@INPUT ptr Pointer to device file data.
;@OUTPUT pointer-to-pointer to device file data if device is open, 0 otherwise
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_SearchDeviceTable:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_device_table
	ld b,open_device_table.len / 4 - 1
.check_loop:
	ld a,(iy)
	ld de,(iy+1)
	lea iy,iy+4
	or a,a
	jr z,.check_next ; found empty entry
	sbc hl,de
	add hl,de
	jr z,.device_open ; found same file data pointer in table, return true
.check_next:
	djnz .check_loop
.device_closed:
	xor a,a
	sbc hl,hl
	db $01 ; ld bc,... dummify lea hl,iy-3
.device_open:
	lea hl,iy-3
	or a,a
	pop iy
	ret
