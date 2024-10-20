;@DOES Return a pointer to a device structure (if valid)
;@INPUT device_t* drv_OpenDeviceFD(void* fd);
;@INPUT fd File descriptor to open as device.
;@OUTPUT pointer to device structure, -1 if failed.
drv_OpenDeviceFD:
	pop bc,hl
	push hl,bc
.entryhl:=drv_OpenDevice.entryfd
	jq drv_OpenDevice.entryfd
