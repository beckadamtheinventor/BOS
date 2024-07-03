;@DOES Write a character to a device file given a descriptor
;@INPUT int drv_PutChar(void* fd, int c);
;@OUTPUT Depends on device, usually number of bytes written.
drv_PutChar:
	pop bc,hl,de
	push de,hl,bc
.entryhlde:
	ld bc,device_JumpWrite
	add hl,bc
	ld a,(hl)
	sub a,$C3
	ret z
	push de ; push stack memory to write from
	ld de,0
	push de ; offset 0
	inc e
	push de ; length 1
	ex hl,de
	ld hl,6
	add hl,sp
	push hl ; push pointer to stack memory to write from
	ex hl,de
	call sys_jphl
	pop bc,bc,bc,bc
	ret
