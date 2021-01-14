
include '../include/bosfs.inc'
fs_fs
fs_dir root_of_roots
	fs_entry dirs.root, "bosfs512", "fs", f_subdir+f_readonly+f_system
end fs_dir
fs_dir dirs.root
	fs_entry dirs.root.fs, "fs", "", f_subdir+0
	fs_entry dirs.root.home, "home", "", f_subdir+0
	fs_entry dirs.root.include, "include", "", f_subdir+0
	fs_entry dirs.root.usr, "usr", "", f_subdir+0
	fs_entry dirs.root.etc, "etc", "", f_subdir+0
	fs_entry dirs.root.dev, "dev", "", f_subdir+0
	fs_entry dirs.root.bin, "bin", "", f_subdir+0
	fs_entry dirs.root.root, "root", "", f_subdir+0
	fs_entry dirs.root.lib, "lib", "", f_subdir+0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0
	fs_entry files.lib, "lib", "", 0

end fs_dir

fs_file dirs.root.fs

end fs_dir

fs_file dirs.root.home

end fs_dir

fs_dir dirs.root.home
	fs_entry dirs.root.home.user, "user", "", f_subdir+0

end fs_dir

fs_file dirs.root.home.user

end fs_dir

fs_file dirs.root.include

end fs_dir

fs_file dirs.root.usr

end fs_dir

fs_file dirs.root.etc

end fs_dir

fs_file dirs.root.dev

end fs_dir

fs_file dirs.root.bin

end fs_dir

fs_file dirs.root.lib

end fs_dir

fs_file files.lib
	file 'fs/bin/usbsend.bin'
end fs_file

fs_file files.lib
	file 'fs/bin/usbrun.bin'
end fs_file

fs_file files.lib
	file 'fs/bin/explorer.bin'
end fs_file

fs_file files.lib
	file 'fs/bin/memedit.bin'
end fs_file

fs_file files.lib
	file 'fs/bin/tedit.bin'
end fs_file

fs_file files.lib
	file 'fs/bin/fexplore.bin'
end fs_file

fs_file files.lib
	file 'fs/lib/FONTLIBC.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/FONTLIBC.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/SRLDRVCE.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/GRAPHX.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/KEYPADC.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/FATDRVCE.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/SRLDRVCE.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/LibLoad.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/LibLoad.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/USBDRVCE.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/FILEIOC.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/KEYPADC.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/FATDRVCE.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/USBDRVCE.lib'
end fs_file

fs_file files.lib
	file 'fs/lib/GRAPHX.LLL'
end fs_file

fs_file files.lib
	file 'fs/lib/FILEIOC.lib'
end fs_file



end fs_fs
