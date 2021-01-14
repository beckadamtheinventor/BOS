
current_dir := bos.open_files_table

virtual at bos.usbRAM
	usb_device:
	msd_device:  rb 23
	partition_descriptor: rb 7
	fat_device: rb 64
	fat_volume_label: rb 18
	fat_dir_entries: rb 18*8
end virtual

