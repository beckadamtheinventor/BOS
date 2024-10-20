;@DOES Write to a device file given a descriptor
;@INPUT int drv_Write(device_t* ptr, void *buffer, size_t len, size_t offset);
;@INPUT ptr Pointer to device file data.
;@INPUT buffer Pointer to data to write.
;@INPUT len Length of data to write, in bytes.
;@INPUT offset Offset in file to write data.
;@OUTPUT Number of bytes written.
drv_Write:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,device_JumpWrite
	jr drv.common_3_args
