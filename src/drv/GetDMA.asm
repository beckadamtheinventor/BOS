;@DOES Return a pointer to a device's physical memory address
;@INPUT void *drv_GetDMA(void* fd);
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
