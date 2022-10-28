str_bosfs512_partition_header: ; TODO: this shouldn't be static
	db "bosfs040fs ", $14
	dw fs_root_dir_lba ; LBA of the root directory
	dw (end_of_user_archive - start_of_user_archive) shr 9 ; size of partition in LBAs
.len:=$-.
