;@DOES Read a character from a device file given a descriptor
;@INPUT int drv_GetChar(device_t* ptr);
;@INPUT ptr Pointer to device file data.
;@OUTPUT Data (usually a character) read from device.
drv_DeinitDevice:
	pop bc,hl
	push hl,bc
.entryhl:
	ld bc,device_JumpDeinit
	jq drv.common_no_args
