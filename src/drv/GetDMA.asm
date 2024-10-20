;@DOES Return a pointer to a device's physical memory address, if applicable.
;@INPUT void *drv_GetDMA(device_t* ptr);
;@INPUT ptr Pointer to device file data.
;@OUTPUT pointer to address, 0 if not applicable.
drv_GetDMA:
	pop bc,hl
	push hl,bc
.entryhl:
	ld bc,device_JumpGetDMA
drv.common_no_args:
	add hl,bc
	ld a,(hl)
	cp a,$C3
	ret nz
	jp (hl)
