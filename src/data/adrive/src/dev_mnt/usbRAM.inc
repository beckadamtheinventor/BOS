

virtual at bos.usbRAM
	usb_device:             rb 3
	msd_device:             rb 23
	partition_descriptor:   rb 7
	fat_device:             rb 64
	fat_volume_label:       rb 18
	fat_dir_entries:        rb 18*8
	current_dir_ptr:        rb 3
end virtual

virtual at bos.reservedRAM
;db $C0,"USBDRVCE",0,0
	rb 11
	usb_Init:                 rb 3
	usb_Cleanup:              rb 3
	usb_HandleEvents:         rb 3
	usb_WaitForInterrupt:     rb 3
	usb_ResetDevice:          rb 3

;db $C0,"FATDRVCE",0,1
	rb 11
	msd_Init:	rb 3
	msd_IsInit:	rb 3
	msd_Deinit:	rb 3
	msd_Reset:	rb 3
	msd_GetSectorCount:	rb 3
	msd_GetSectorSize:	rb 3
	msd_ReadSectors:	rb 3
	msd_WriteSectors:	rb 3
	fat_Find:	rb 3
	fat_Init:	rb 3
	fat_Deinit:	rb 3
	fat_DirList:	rb 3
	fat_GetVolumeLabel:	rb 3
	fat_Open:	rb 3
	fat_Close:	rb 3
	fat_SetSize:	rb 3
	fat_GetSize:	rb 3
	fat_SetAttrib:	rb 3
	fat_GetAttrib:	rb 3
	fat_SetFilePos:	rb 3
	fat_GetFilePos:	rb 3
	fat_ReadSectors:	rb 3
	fat_WriteSectors:	rb 3
	fat_Create:	rb 3
	fat_Delete:	rb 3
end virtual
