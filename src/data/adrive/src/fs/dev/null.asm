
; /dev/null device type memory, r/w + DMA r/w, version 2, handling no interrupts.
device_file devtMemory, mDeviceReadable or mDeviceWritable or mDeviceHasDMA or mDeviceDMAReadable or mDeviceDMAWritable, 2, deviceIntNone
	export device_JumpRead,      dev_null_read
	export device_JumpWrite,     dev_null_write
	export device_JumpGetDMA,    dev_null_get_location
dev_null_get_location:
	ld hl,$FF0000
	ret
dev_null_read:
	pop hl,de,bc
	push bc,de,hl
	ld hl,$FF0000
	ldir
	ret
dev_null_write: ; dummy write
	pop hl,de,bc
	push bc,de,hl
	add hl,bc
	ex hl,de
	ld hl,$FF0000
	add hl,bc
	ex hl,de
	ld bc,0
	ret
end device_file
