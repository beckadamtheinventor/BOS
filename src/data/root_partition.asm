str_bosfs512_partition_header: ; TODO: this shouldn't be static
	db "bosfs040fs ", $14
	dw fs_root_dir_lba ; LBA of the root directory
	dw fs_directory_size*2 ; size of root dir
.len:=$-.
