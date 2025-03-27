fs_root_dir_data:
	db "bin        ", $14
    dw ($300+fs_directory_size)/$40, fs_directory_size
	db "dev        ", $14
    dw ($200+fs_directory_size)/$40, fs_directory_size
	db "lib        ", $14
    dw ($100+fs_directory_size)/$40, fs_directory_size
	db "sbin       ", $14
    dw ($000+fs_directory_size)/$40, fs_directory_size
.len:=$-.
