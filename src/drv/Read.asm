;@DOES Read from a device file given a descriptor
;@INPUT int drv_Read(void* fd, void *buffer, size_t len, size_t offset);
;@OUTPUT Number of bytes read.
drv_Read:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,device_JumpRead
drv.common_3_args: ; space savings for drv_Write
	add hl,bc
	ld a,(hl)
	cp a,$C3
	ret nz
	ld de,(ix+15) ; offset
	push de
	ld de,(ix+12) ; len
	push de
	ld de,(ix+9) ; buffer
	push de
	call sys_jphl
	ld sp,ix
	pop ix
	ret
