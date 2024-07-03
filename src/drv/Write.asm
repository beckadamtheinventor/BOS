;@DOES Write to a device file given a descriptor
;@INPUT int drv_Write(void* fd, void *buffer, size_t len, size_t offset);
;@OUTPUT Number of bytes written.
drv_Write:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,device_JumpWrite
	jr drv.common_3_args
