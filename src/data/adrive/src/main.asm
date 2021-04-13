
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

;fs_dir root_of_roots_dir
	fs_entry root_dir, "bosfs512", "fs", f_readonly+f_system+f_subdir
	db 496 dup $FF
;end fs_dir

fs_dir root_dir
	fs_entry bin_dir, "bin", "", f_readonly+f_system+f_subdir
	fs_entry dev_dir, "dev", "", f_readonly+f_system+f_subdir
	fs_entry boot_dir, "boot", "", f_readonly+f_system+f_subdir
	fs_entry etc_dir, "etc", "", f_subdir
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_readonly+f_system+f_subdir
	fs_entry opt_dir, "opt", "", f_subdir
	fs_entry sbin_dir, "sbin", "", f_readonly+f_system+f_subdir
	fs_entry tmp_dir, "tmp", "", f_subdir
	fs_entry usr_dir, "usr", "", f_subdir
end fs_dir

;"/bin/" directory
fs_dir bin_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry boot_exe, "boot", "", f_readonly+f_system
	fs_entry bpkload_exe, "bpk", "", f_readonly+f_system
	fs_entry bpm_exe, "bpm", "", f_readonly+f_system
	fs_entry cat_exe, "cat", "", f_readonly+f_system
	fs_entry cd_exe, "cd", "", f_readonly+f_system
	fs_entry cmd_exe, "cmd", "", f_readonly+f_system
	fs_entry cls_exe, "cls", "", f_readonly+f_system
	fs_entry cp_exe, "cp", "", f_readonly+f_system
	fs_entry initdev_exe, "device", "", f_readonly+f_system
	fs_entry df_exe, "df", "", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "", f_readonly+f_system
	fs_entry fexplore_exe, "fexplore", "", f_readonly+f_system
	fs_entry info_exe, "info", "", f_readonly+f_system
	fs_entry ls_exe, "ls", "", f_readonly+f_system
	fs_entry memedit_exe, "memedit", "", f_readonly+f_system
	fs_entry mkdir_exe, "mkdir", "", f_readonly+f_system
	fs_entry mkfile_exe, "mkfile", "", f_readonly+f_system
	fs_entry off_exe, "off", "", f_readonly+f_system
	fs_entry rm_exe, "rm", "", f_readonly+f_system
	fs_entry usbrecv_exe, "usbrecv", "", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun", "", f_readonly+f_system
	fs_entry usbsend_exe, "usbsend", "", f_readonly+f_system
end fs_dir

fs_dir boot_dir
	fs_entry root_dir, "..", "", f_subdir
end fs_dir

;"/dev/" directory
fs_dir dev_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry cluster_map_file, "cmap", "dat", f_readonly+f_system
	fs_entry dev_lcd, "lcd", "", f_readonly+f_system+f_device
	fs_entry dev_null, "null", "", f_readonly+f_system+f_device
	fs_entry dev_mnt, "mnt", "", f_readonly+f_system+f_device
end fs_dir

;"/etc/" directory
fs_dir etc_dir
	fs_entry root_dir, "..", "", f_subdir
end fs_dir

;"/lib/" directory
fs_dir lib_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry fatdrvce_lll, "FATDRVCE","dll", f_readonly+f_system
	fs_entry fileioc_lll, "FILEIOC","dll", f_readonly+f_system
	fs_entry fontlibc_lll, "FONTLIBC","dll", f_readonly+f_system
	fs_entry graphx_lll, "GRAPHX","dll", f_readonly+f_system
	fs_entry keypadc_lll, "KEYPADC", "dll", f_readonly+f_system
	fs_entry srldrvce_lll, "SRLDRVCE","dll", f_readonly+f_system
	fs_entry usbdrvce_lll, "USBDRVCE","dll", f_readonly+f_system
	fs_entry libload_lll, "LibLoad", "dll", f_readonly+f_system
end fs_dir

;"/opt/" directory
fs_dir opt_dir
	fs_entry root_dir, "..", "", f_subdir
end fs_dir

;"/sbin/" directory
fs_dir sbin_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry fsutil_exe, "fsutil", "", f_readonly+f_system
	fs_entry uninstaller_exe, "uninstlr", "", f_readonly+f_system
	fs_entry updater_exe, "updater", "", f_readonly+f_system
end fs_dir

;"/tmp/" directory
fs_dir tmp_dir
	fs_entry root_dir, "..", "", f_subdir
end fs_dir

;"/usr/" directory
fs_dir usr_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry usr_bin_dir, "bin", "", f_subdir
	fs_entry usr_lib_dir, "lib", "", f_subdir
	fs_entry tivars_dir, "tivars", "", f_subdir
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

;"/home/" directory
fs_dir home_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry user_dir, "user", "", f_subdir
end fs_dir

;"/home/user/" directory
fs_dir user_dir
	fs_entry home_dir, "..", "", f_subdir
end fs_dir

;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file cluster_map_file
	db 7040 dup $FF
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
	include 'fs/bin/boot.asm'
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

fs_file cp_exe
	include 'fs/bin/cp.asm'
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

fs_file initdev_exe
	include 'fs/bin/device.asm'
end fs_file

fs_file usbrecv_exe
	file '../obj/usbrecv.bin'
end fs_file

fs_file bpkload_exe
	file '../obj/bpkload.bin'
end fs_file

fs_file df_exe
	include 'fs/bin/df.asm'
end fs_file

fs_file fsutil_exe
	include 'fs/bin/fsutil.asm'
end fs_file

fs_file bpm_exe
	file '../obj/bpm.bin'
end fs_file

end fs_fs

