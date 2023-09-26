
; /dev/bosfs040 device type FS, r/w + DMA r, version 1, handling no interrupts, r/w fs
device_file devtFS, mDeviceReadable or mDeviceWritable or mDeviceHasDMA or mDeviceDMAReadable, 1, deviceIntNone, mDeviceFSReadable or mDeviceFSWritable
	export device_JumpRead,      bosfs040_read
	export device_JumpGetDMA,    bosfs040_get_loc
bosfs040_get_loc:
bosfs040_read:
	scf
	sbc hl,hl
	ret
end device_file
