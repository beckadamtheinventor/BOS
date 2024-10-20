;@DOES check if a device (by file descriptor) is open or not
;@INPUT void** sys_SearchDeviceTable(void* ptr);
;@INPUT ptr Pointer to device file data
;@OUTPUT pointer-to-pointer to device file data if device is open, 0 otherwise
;@NOTE Each device table entry is 4 bytes. 1 byte flags, 3 byte file descriptor.
sys_SearchDeviceTableFD:
	pop bc,hl
	push hl,bc
	call sys_GetFDPtr
	inc hl ; adjust for error value -1
	ret c
	dec hl
	jr sys_SearchDeviceTable.entryhl
