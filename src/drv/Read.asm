;@DOES Read from a device file given a descriptor
;@INPUT int drv_Read(device_t* ptr, void *buffer, size_t len, size_t offset);
;@INPUT ptr Pointer to device file data.
;@INPUT buffer Pointer to read data into.
;@INPUT len Length of data to read, in bytes.
;@INPUT offset Offset to read data from.
;@OUTPUT Number of bytes read.
drv_Read:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,device_JumpRead
drv.common_3_args: ; space savings for drv_Write
	add hl,bc
	ld a,(hl)
	cp a,$C3
	jr nz,drv.common_stack_exit
	ld de,(ix+15) ; offset
	push de
	ld de,(ix+12) ; len
	push de
	ld de,(ix+9) ; buffer
drv.common_push_de_call_hl:
	push de
	call sys_jphl
drv.common_stack_exit:
	ld sp,ix
	pop ix
	ret
