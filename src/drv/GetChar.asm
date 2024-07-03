;@DOES Read a character from a device file given a descriptor
;@INPUT int drv_GetChar(void* fd);
;@OUTPUT Data (usually a character) read from device.
drv_GetChar:
	pop bc,hl
	push hl,bc
.entryhl:
	ld bc,device_JumpRead
	add hl,bc
	ld a,(hl)
	cp a,$C3
	ret nz
	ld de,0
	push de ; push stack memory to read into
	push de ; offset 0
	inc e
	push de ; length 1
	ex hl,de
	ld hl,6
	add hl,sp
	push hl ; push pointer to stack memory to read into
	ex hl,de
	call sys_jphl
	pop bc,bc,bc,hl
	ret
