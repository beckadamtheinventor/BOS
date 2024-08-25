
; /dev/random device type memory, r, version 2, handling no interrupts.
device_file devtMemory, mDeviceReadable, 2, deviceIntNone
	export device_JumpRead,      dev_random_read
dev_random_read:
	pop hl,bc,de
	push de,bc,hl
.loop:
	push bc
	call bos.sys_Random8
	pop bc
	ld (de),a
	inc de
	cpi
	ret po
	jr .loop
end device_file
