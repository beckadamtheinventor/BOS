
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'

org $040000
fs_fs

;-------------------------------------------------------------
;directory listings section
;-------------------------------------------------------------

;filesystem root directory entries

fs_dir root_of_roots_dir
	fs_entry root_dir, "bosfs512", "fs", f_readonly+f_system+f_subdir
end fs_dir

fs_dir root_dir
	fs_entry bin_dir, "bin", "", f_readonly+f_system+f_subdir
	fs_entry boot_dir, "boot", "", f_readonly+f_system+f_subdir
	fs_entry dev_dir, "dev", "", f_readonly+f_system+f_subdir
	fs_entry etc_dir, "etc", "", f_subdir
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_readonly+f_system+f_subdir
	fs_entry usr_dir, "usr", "", f_subdir
end fs_dir

;"/bin/" directory
fs_dir bin_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry bpkload_exe, "bpk", "exe", f_readonly+f_system
	fs_entry cat_exe, "cat", "exe", f_readonly+f_system
	fs_entry cd_exe, "cd", "exe", f_readonly+f_system
	fs_entry cmd_exe, "cmd","exe", f_readonly+f_system
	fs_entry cls_exe, "cls", "exe", f_readonly+f_system
	fs_entry initdev_exe, "dev", "exe", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "exe", f_readonly+f_system
	fs_entry fexplore_exe, "fexplore", "exe", f_readonly+f_system
	fs_entry files_exe, "files", "exe", f_readonly+f_system
	fs_entry info_exe, "info", "exe", f_readonly+f_system
	fs_entry ls_exe, "ls", "exe", f_readonly+f_system
	fs_entry memedit_exe, "memedit","exe", f_readonly+f_system
	fs_entry mkdir_exe, "mkdir", "exe", f_readonly+f_system
	fs_entry mkfile_exe, "mkfile", "exe", f_readonly+f_system
	fs_entry off_exe, "off","exe", f_readonly+f_system
	fs_entry rm_exe, "rm", "exe", f_readonly+f_system
	fs_entry uninstaller_exe, "uninstlr","exe", f_readonly+f_system
	fs_entry updater_exe, "updater", "exe", f_readonly+f_system
	fs_entry usbrecv_exe, "usbrecv","exe", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun","exe", f_readonly+f_system
	fs_entry usbsend_exe, "usbsend","exe", f_readonly+f_system
	fs_entry userfsck_exe, "userfsck", "exe", f_readonly+f_system
end fs_dir

;"/boot/" directory
fs_dir boot_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry boot_exe, "boot", "exe", f_readonly+f_system
	fs_entry boot_usr, "usr", "", f_subdir
end fs_dir

;"/dev/" directory
fs_dir dev_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry cluster_map_file, "cmap", "dat", f_readonly+f_system
	fs_entry dev_lcd, "lcd", "", f_readonly+f_system+f_device
	fs_entry dev_null, "null", "", f_readonly+f_system+f_device
	fs_entry dev_mnt, "mnt", "", f_readonly+f_system+f_device
end fs_dir

;"/lib/" directory
fs_dir lib_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry fatdrvce_lll, "FATDRVCE","LLL", f_readonly+f_system
	fs_entry fileioc_lll, "FILEIOC","LLL", f_readonly+f_system
	fs_entry fontlibc_lll, "FONTLIBC","LLL", f_readonly+f_system
	fs_entry graphx_lll, "GRAPHX","LLL", f_readonly+f_system
	fs_entry keypadc_lll, "KEYPADC", "LLL", f_readonly+f_system
	fs_entry srldrvce_lll, "SRLDRVCE","LLL", f_readonly+f_system
	fs_entry usbdrvce_lll, "USBDRVCE","LLL", f_readonly+f_system
	fs_entry libload_lll, "LibLoad", "LLL", f_readonly+f_system
end fs_dir

;"/boot/usr/" directory
fs_dir boot_usr
	fs_entry boot_dir, "..", "", f_subdir
end fs_dir

;"/etc/" directory
fs_dir etc_dir
	fs_entry root_dir, "..", "", f_subdir
end fs_dir

;"/home/" directory
fs_dir home_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry user_home_dir, "user", "", f_subdir
end fs_dir

;"/usr/" directory
fs_dir usr_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry usr_bin_dir, "bin", "", f_subdir
	fs_entry usr_lib_dir, "lib", "", f_subdir
	fs_entry tivars_dir, "tivars", "", f_subdir
end fs_dir

;"/home/user/" directory
fs_dir user_home_dir
	fs_entry home_dir, "..", "", f_subdir
end fs_dir

;"/usr/tivars/" directory
fs_dir tivars_dir
	fs_entry usr_dir, "..", "", f_subdir
end fs_dir

;"/usr/bin/" directory
fs_dir usr_bin_dir
	fs_entry usr_dir, "..", "", f_subdir
end fs_dir

;"/usr/lib/" directory
fs_dir usr_lib_dir
	fs_entry usr_dir, "..", "", f_subdir
end fs_dir



;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file cluster_map_file
	db 8192 dup $FF
end fs_file

fs_file off_exe
	include 'fs/bin/off.asm'
end fs_file

fs_file dev_mnt
	include 'fs/dev/mnt.asm'
end fs_file

fs_file dev_null
	include 'fs/dev/null.asm'
end fs_file

fs_file dev_lcd
	include 'fs/dev/lcd.asm'
end fs_file


fs_file cmd_exe
	include 'fs/bin/cmd.asm'
end fs_file


fs_file boot_exe
	include 'fs/boot/boot.asm'
end fs_file

fs_file cat_exe
	include 'fs/bin/cat.asm'
end fs_file


fs_file cd_exe
	include 'fs/bin/cd.asm'
end fs_file


fs_file cls_exe
	include 'fs/bin/cls.asm'
end fs_file


fs_file explorer_exe
	file '../obj/explorer.bin'
end fs_file


fs_file fexplore_exe
	file '../obj/fexplore.bin'
end fs_file



fs_file ls_exe
	include 'fs/bin/ls.asm'
end fs_file

fs_file fatdrvce_lll
	file '../obj/fatdrvce.bin'
end fs_file

fs_file fileioc_lll
	file '../obj/fileioc.bin'
end fs_file

fs_file fontlibc_lll
	file '../obj/fontlibc.bin'
end fs_file

fs_file graphx_lll
	file '../obj/graphx.bin'
end fs_file

fs_file keypadc_lll
	file '../obj/keypadc.bin'
end fs_file

fs_file srldrvce_lll
	file '../obj/srldrvce.bin'
end fs_file

fs_file usbdrvce_lll
	file '../obj/usbdrvce.bin'
end fs_file

fs_file libload_lll
	file '../obj/bos_libload.bin'
end fs_file


fs_file uninstaller_exe
	include 'fs/bin/uninstlr.asm'
end fs_file

fs_file updater_exe
	include 'fs/bin/updater.asm'
end fs_file

fs_file memedit_exe
	file '../obj/memedit.bin'
end fs_file

fs_file usbrun_exe
	file "../obj/usbrun.bin"
end fs_file

fs_file usbsend_exe
	file "../obj/usbsend.bin"
end fs_file

fs_file info_exe
	include 'fs/bin/info.asm'
end fs_file

fs_file rm_exe
	include 'fs/bin/rm.asm'
end fs_file


fs_file mkdir_exe
	include 'fs/bin/mkdir.asm'
end fs_file


fs_file mkfile_exe
	include 'fs/bin/mkfile.asm'
end fs_file

fs_file files_exe
	file '../obj/files.bin'
end fs_file


fs_file initdev_exe
	include 'fs/bin/dev.asm'
end fs_file

fs_file userfsck_exe
	include 'fs/bin/userfsck.asm'
end fs_file

fs_file usbrecv_exe
	file '../obj/usbrecv.bin'
end fs_file

fs_file bpkload_exe
	file '../obj/bpkload.bin'
end fs_file


end fs_fs

