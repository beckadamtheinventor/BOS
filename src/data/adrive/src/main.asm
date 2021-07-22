
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'
include 'include/threading.inc'
include 'include/bos_trx.inc'

org $040000
fs_fs

;-------------------------------------------------------------
;directory listings section
;-------------------------------------------------------------

;filesystem root directory entries

;fs_dir root_of_roots_dir
	fs_entry root_dir, "bosfs512", "fs", f_system+f_subdir
	db 496 dup $FF
;end fs_dir

fs_dir root_dir
	fs_entry bin_dir, "bin", "", f_system+f_subdir
	fs_entry dev_dir, "dev", "", f_system+f_subdir
	fs_entry etc_dir, "etc", "", f_subdir
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_system+f_subdir
	fs_entry opt_dir, "opt", "", f_subdir
	fs_entry sbin_dir, "sbin", "", f_system+f_subdir
	fs_entry tmp_dir, "tmp", "", f_subdir
	fs_entry usr_dir, "usr", "", f_subdir
	fs_entry var_dir, "var", "", f_subdir
;	fs_longentry test_name_file, "testing.testing.123.hello", 0 ;coming soon :D
end fs_dir

;"/bin/" directory
fs_dir bin_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_sfentry writeinto_exe, ">", "", f_readonly+f_system+f_subfile
	fs_sfentry appendinto_exe, ">>", "", f_readonly+f_system+f_subfile
	fs_sfentry boot_exe, "boot", "", f_readonly+f_system+f_subfile
	fs_entry bpkload_exe, "bpk", "", f_readonly+f_system
	; fs_entry bpm_exe, "bpm", "", f_readonly+f_system
	fs_sfentry cat_exe, "cat", "", f_readonly+f_system+f_subfile
	fs_sfentry cd_exe, "cd", "", f_readonly+f_system+f_subfile
	fs_sfentry cmd_exe, "cmd", "", f_readonly+f_system+f_subfile
	fs_sfentry cls_exe, "cls", "", f_readonly+f_system+f_subfile
	fs_sfentry cp_exe, "cp", "", f_readonly+f_system+f_subfile
	fs_sfentry initdev_exe, "device", "", f_readonly+f_system+f_subfile
	fs_sfentry df_exe, "df", "", f_readonly+f_system+f_subfile
	fs_entry echo_exe, "echo", "", f_readonly+f_system
	; fs_entry edit_exe, "edit", "", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "", f_readonly+f_system
	; fs_entry fexplore_exe, "fexplore", "", f_readonly+f_system
	fs_sfentry info_exe, "info", "", f_readonly+f_system+f_subfile
	fs_sfentry ls_exe, "ls", "", f_readonly+f_system+f_subfile
	fs_entry memedit_exe, "memedit", "", f_readonly+f_system
	fs_sfentry mkdir_exe, "mkdir", "", f_readonly+f_system+f_subfile
	fs_sfentry mkfile_exe, "mkfile", "", f_readonly+f_system+f_subfile
	fs_sfentry off_exe, "off", "", f_readonly+f_system+f_subfile
	fs_sfentry rm_exe, "rm", "", f_readonly+f_system+f_subfile
	fs_entry serial_exe, "serial", "", f_readonly+f_system
	; fs_entry transfer_exe, "transfer", "", f_readonly+f_system
	fs_entry usbrecv_exe, "usbrecv", "", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun", "", f_readonly+f_system
	; fs_entry usbsend_exe, "usbsend", "", f_readonly+f_system
end fs_dir

fs_dir var_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry path_var, "PATH", "", 0
end fs_dir

fs_subfile boot_exe, bin_dir
	include 'fs/bin/boot.asm'
end fs_subfile

fs_subfile writeinto_exe, bin_dir
	include 'fs/bin/writeinto.asm'
end fs_subfile

fs_subfile appendinto_exe, bin_dir
	include 'fs/bin/appendinto.asm'
end fs_subfile

fs_subfile cat_exe, bin_dir
	include 'fs/bin/cat.asm'
end fs_subfile

fs_subfile cd_exe, bin_dir
	include 'fs/bin/cd.asm'
end fs_subfile

fs_subfile cls_exe, bin_dir
	include 'fs/bin/cls.asm'
end fs_subfile

fs_subfile initdev_exe, bin_dir
	include 'fs/bin/device.asm'
end fs_subfile

fs_subfile df_exe, bin_dir
	include 'fs/bin/df.asm'
end fs_subfile

fs_subfile cmd_exe, bin_dir
	include 'fs/bin/cmd.asm'
end fs_subfile

fs_subfile ls_exe, bin_dir
	include 'fs/bin/ls.asm'
end fs_subfile

fs_subfile cp_exe, bin_dir
	include 'fs/bin/cp.asm'
end fs_subfile

fs_subfile info_exe, bin_dir
	include 'fs/bin/info.asm'
end fs_subfile

fs_subfile rm_exe, bin_dir
	include 'fs/bin/rm.asm'
end fs_subfile

fs_subfile mkdir_exe, bin_dir
	include 'fs/bin/mkdir.asm'
end fs_subfile

fs_subfile mkfile_exe, bin_dir
	include 'fs/bin/mkfile.asm'
end fs_subfile

fs_subfile off_exe, bin_dir
	include 'fs/bin/off.asm'
end fs_subfile

;"/dev/" directory
fs_dir dev_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry cluster_map_file, "cmap", "dat", f_readonly+f_system
	fs_sfentry dev_lcd, "lcd", "", f_readonly+f_system+f_device+f_subfile
	fs_sfentry dev_null, "null", "", f_readonly+f_system+f_device+f_subfile
	fs_sfentry dev_mnt, "mnt", "", f_readonly+f_system+f_device+f_subfile
end fs_dir

fs_subfile dev_null, dev_dir
	include 'fs/dev/null.asm'
end fs_subfile

fs_subfile dev_lcd, dev_dir
	include 'fs/dev/lcd.asm'
end fs_subfile

fs_subfile dev_mnt, dev_dir
	include 'fs/dev/mnt.asm'
end fs_subfile

;"/etc/" directory
fs_dir etc_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry etc_config_dir, "config", "", f_subdir
	fs_entry etc_data_dir, "data", "", f_subdir
	fs_entry etc_plugins_dir, "plugins", "", f_subdir
end fs_dir

;"/etc/config/" directory
fs_dir etc_config_dir
	fs_entry etc_dir, "..", "", f_subdir
	fs_entry etc_config_explorer_dir, "explorer", "", f_subdir
end fs_dir

;"/etc/data/" directory
fs_dir etc_data_dir
	fs_entry etc_dir, "..", "", f_subdir
	; fs_entry transfer_dir, "TRANSFER", "", f_subdir
	fs_entry etc_data_explorer_dir, "explorer", "", f_subdir
end fs_dir


;"/etc/data/explorer/" directory
fs_dir etc_data_explorer_dir
	fs_entry etc_data_dir, "..", "", f_subdir
	; fs_entry explorer_font_file, "font", "bin", 0
end fs_dir

;"/etc/data/TRANSFER/" directory
; fs_dir transfer_dir
	; fs_entry etc_data_dir, "..", "", f_subdir
	; fs_entry font_data_file, "font", "bin", 0
; end fs_dir

;"/etc/config/explorer/" directory
fs_dir etc_config_explorer_dir
	fs_entry etc_config_dir, "..", "", f_subdir
	fs_entry explorer_cfg, "explorer", "cfg", 0
	fs_entry missing_icon, "missing", "ico", 0
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

;"/etc/plugins/" directory
fs_dir etc_plugins_dir
	fs_entry etc_dir, "..", "", f_subdir
	fs_entry etc_plugins_explorer_dir, "explorer", "", f_subdir
end fs_dir

;"/etc/plugins/explorer/" directory
fs_dir etc_plugins_explorer_dir
	fs_entry etc_plugins_dir, "..", "", f_subdir
	fs_entry explorer_blconfig_dir, "blconfig", "", f_subdir
	; fs_entry explorer_serial_dir, "serial", "", f_subdir
end fs_dir

;"/etc/plugins/explorer/blconfig/" directory
fs_dir explorer_blconfig_dir
	fs_entry etc_plugins_explorer_dir, "..", "", f_subdir
	fs_entry explorer_blconfig_exe, "blconfig", "", 0
	fs_entry explorer_blconfig_cmd, "index", "cmd", 0
end fs_dir

;"/etc/plugins/explorer/serial/" directory
; fs_dir explorer_serial_dir
	; fs_entry etc_plugins_explorer_dir, "..", "", f_subdir
	; fs_entry explorer_serial_cmd, "index", "cmd", 0
	; fs_entry explorer_serial_exe, "serial", "", 0
; end fs_dir

;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file cluster_map_file
	db bos.fs_cmap_length dup $FF
end fs_file

fs_file explorer_exe
	file '../obj/explorer.bin'
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

fs_file echo_exe
	include 'fs/bin/echo.asm'
end fs_file

; fs_file fexplore_exe
	; file '../obj/fexplore.bin'
; end fs_file

fs_file memedit_exe
	file '../obj/memedit.bin'
end fs_file

fs_file usbrun_exe
	file "../obj/usbrun.bin"
end fs_file

; fs_file usbsend_exe
	; file "../obj/usbsend.bin"
; end fs_file

fs_file usbrecv_exe
	file '../obj/usbrecv.bin'
end fs_file

fs_file bpkload_exe
	file '../obj/bpkload.bin'
end fs_file

fs_file fsutil_exe
	include 'fs/bin/fsutil.asm'
end fs_file

; fs_file bpm_exe
	; file '../obj/bpm.bin'
; end fs_file

; fs_file edit_exe
	; file '../obj/edit.bin'
; end fs_file

; fs_file explorer_font_file
	; file 'fs/etc/data/explorer/font.bin'
; end fs_file

; fs_file font_data_file
	; file 'fs/etc/data/TRANSFER/font.bin'
; end fs_file

; fs_file transfer_exe
	; file 'fs/bin/TRANSFER.bin'
; end fs_file

fs_file missing_icon
	include 'fs/etc/config/explorer/missing.asm'
end fs_file

fs_file explorer_cfg
	file 'fs/etc/config/explorer/explorer.cfg'
end fs_file

fs_file path_var
	db "/bin:/usr/bin:/sbin"
end fs_file

fs_file explorer_blconfig_exe
	include 'fs/etc/plugins/explorer/blconfig/blconfig.asm'
end fs_file

fs_file explorer_blconfig_cmd
	db "blconfig",$A,0
end fs_file

; fs_file explorer_serial_exe
	; include 'fs/etc/plugins/explorer/serial/serial.asm'
; end fs_file

; fs_file explorer_serial_cmd
	; db "serial",$A,0
; end fs_file

fs_file serial_exe
	file 'fs/bin/serial/bosbin/serial.bin'
end fs_file

end fs_fs

