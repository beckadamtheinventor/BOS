;@DOES Write a string to a device file given a descriptor
;@INPUT int drv_WriteStr(device_t* ptr, char *str, size_t offset);
;@INPUT ptr Pointer to device file data.
;@INPUT str Pointer to string to write.
;@INPUT offset Offset in file to write data.
;@OUTPUT Number of bytes written.
drv_WriteStr:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,device_JumpWrite
	add hl,bc
	ld a,(hl)
	cp a,$C3
	ret nz
	ld (ti.scrapMem),hl
	ld de,(ix+12) ; offset
	push de
	ld de,(ix+9) ; str
	push de
	call ti._strlen
	ex (sp),hl ; len
	push hl ; str
	ld hl,(ti.scrapMem)
	call sys_jphl
	ld sp,ix
	pop ix
	ret
