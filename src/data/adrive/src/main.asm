
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'


org $040000+bos.fs_directory_size
fs_fs $040000

;-------------------------------------------------------------
;directory listings section
;-------------------------------------------------------------

; this is written starting at LBA=1

;"/sbin/" directory
fs_dir sbin_dir
	; fs_entry root_dir, "..", "", f_subdir
	fs_sfentry gc_cmd, "gc", "", f_system+f_subfile
	fs_sfentry gc_cmd, "cleanup", "", f_system+f_subfile
	fs_sfentry fsutil_exe, "fsutil", "", f_system+f_subfile
	fs_sfentry uninstaller_exe, "uninstlr", "", f_system+f_subfile
	; fs_entry updater_exe, "updater", "", f_system
end fs_dir

;"/lib/" directory
fs_dir lib_dir
	; fs_entry root_dir, "..", "", f_subdir
	fs_entry fatdrvce_lll, "FATDRVCE","dll", f_system
	fs_entry fileioc_lll, "FILEIOC","dll", f_system
	fs_entry fontlibc_lll, "FONTLIBC","dll", f_system
	fs_entry graphx_lll, "GRAPHX","dll", f_system
	fs_entry keypadc_lll, "KEYPADC", "dll", f_system
	fs_entry msddrvce_lll, "MSDDRVCE", "dll", f_system
	fs_entry srldrvce_lll, "SRLDRVCE","dll", f_system
	fs_entry usbdrvce_lll, "USBDRVCE","dll", f_system
	fs_entry libload_lll, "LibLoad", "dll", f_system
	fs_entry libload_v15, "LibLoad", "v15", f_system
end fs_dir

;"/bin/" directory
fs_dir bin_dir
	fs_sfentry writeinto_exe, ">", "", f_system+f_subfile
	fs_sfentry appendinto_exe, ">>", "", f_system+f_subfile
	fs_sfentry continuecmd_exe, "@cmd", "", f_system+f_subfile
	fs_entry argv_so, "argv", "so", f_system
	fs_sfentry cat_exe, "cat", "", f_system+f_subfile
	fs_sfentry cd_exe, "cd", "", f_system+f_subfile
	fs_sfentry cmd_exe, "cmd", "", f_system+f_subfile
	fs_sfentry cls_exe, "cls", "", f_system+f_subfile
	fs_sfentry cp_exe, "cp", "", f_system+f_subfile
	; fs_sfentry initdev_exe, "device", "", f_system+f_subfile
	fs_sfentry rm_exe, "del", "", f_system+f_subfile
	fs_sfentry df_exe, "df", "", f_system+f_subfile
	fs_sfentry echo_exe, "echo", "", f_system+f_subfile
	fs_entry explorer_exe, "explorer", "", f_system
	fs_entry memedit_exe, "hexed", "", f_system
	fs_entry memedit_exe, "hexedit", "", f_system
	fs_sfentry mf_exe, "mf", "", f_system+f_subfile
	fs_sfentry info_exe, "info", "", f_system+f_subfile
	fs_sfentry jump_exe, "jump", "", f_system+f_subfile
	; fs_sfentry json_exe, "json", "", f_system+f_subfile
	fs_sfentry ls_exe, "l", "", f_system+f_subfile
	fs_sfentry ls_exe, "la", "", f_system+f_subfile
	fs_sfentry ls_exe, "ls", "", f_system+f_subfile
	fs_entry memedit_exe, "memed", "", f_system
	fs_entry memedit_exe, "memedit", "", f_system
	fs_sfentry mkdir_exe, "md", "", f_system+f_subfile
	fs_sfentry mkdir_exe, "mkd", "", f_system+f_subfile
	fs_sfentry mkdir_exe, "mkdir", "", f_system+f_subfile
	fs_sfentry mkfile_exe, "mk", "", f_system+f_subfile
	fs_sfentry mkfile_exe, "mkf", "", f_system+f_subfile
	fs_sfentry mkfile_exe, "mkfile", "", f_system+f_subfile
	fs_sfentry mv_exe, "mv", "", f_system+f_subfile
	fs_sfentry off_exe, "off", "", f_system+f_subfile
	fs_entry _osrt_lib_table, "osrt", "tbl", f_system
	fs_sfentry pause_exe, "pause", "", f_system+f_subfile
	fs_sfentry peek_exe, "peek", "", f_system+f_subfile
	fs_sfentry poke_exe, "poke", "", f_system+f_subfile
	fs_sfentry rm_exe, "rm", "", f_system+f_subfile
	fs_sfentry sleep_exe, "sleep", "", f_system+f_subfile
	fs_entry str_so, "str", "so", f_system
	; fs_sfentry var_exe, "var", "", f_system+f_subfile
	fs_entry numstr_so, "numstr", "so", f_system
	fs_entry mem_so, "mem", "so", f_system
	fs_entry os_internal_subfiles, "osfiles", "dat", f_system
end fs_dir

fs_file os_internal_subfiles

	fs_subfile gc_cmd, sbin_dir
		db "#!cmd",$A,"fsutil -c",$A
	end fs_subfile

	fs_subfile fsutil_exe, sbin_dir
		include 'fs/sbin/fsutil.asm'
	end fs_subfile

	; fs_subfile var_exe, bin_dir
		; include 'fs/bin/var.asm'
	; end fs_subfile

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

	fs_subfile continuecmd_exe, bin_dir
		include 'fs/bin/@cmd.asm'
	end fs_subfile
	
	fs_subfile cmd_exe, bin_dir
		include 'fs/bin/cmd.asm'
	end fs_subfile

	fs_subfile cls_exe, bin_dir
		include 'fs/bin/cls.asm'
	end fs_subfile

	fs_subfile cp_exe, bin_dir
		include 'fs/bin/cp.asm'
	end fs_subfile

	; fs_subfile initdev_exe, bin_dir
		; include 'fs/bin/device.asm'
	; end fs_subfile

	fs_subfile df_exe, bin_dir
		include 'fs/bin/df.asm'
	end fs_subfile

	fs_subfile mf_exe, bin_dir
		include 'fs/bin/mf.asm'
	end fs_subfile

	fs_subfile ls_exe, bin_dir
		include 'fs/bin/ls.asm'
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

	fs_subfile mv_exe, bin_dir
		include 'fs/bin/mv.asm'
	end fs_subfile

	fs_subfile off_exe, bin_dir
		include 'fs/bin/off.asm'
	end fs_subfile

	fs_subfile sleep_exe, bin_dir
		include 'fs/bin/sleep.asm'
	end fs_subfile

	fs_subfile pause_exe, bin_dir
		include 'fs/bin/pause.asm'
	end fs_subfile

	fs_subfile peek_exe, bin_dir
		include 'fs/bin/peek.asm'
	end fs_subfile

	fs_subfile poke_exe, bin_dir
		include 'fs/bin/poke.asm'
	end fs_subfile

	fs_subfile uninstaller_exe, bin_dir
		include 'fs/sbin/uninstlr.asm'
	end fs_subfile

	fs_subfile echo_exe, bin_dir
		include 'fs/bin/echo.asm'
	end fs_subfile

	fs_subfile jump_exe, bin_dir
		include 'fs/bin/jump.asm'
	end fs_subfile

	; fs_subfile json_exe, bin_dir
		; include 'fs/bin/json.asm'
	; end fs_subfile
end fs_file



;-------------------------------------------------------------
; file data section
;-------------------------------------------------------------

fs_file libload_v15
	db ti.AppVarObj, "LibLoad", 0, 7, 7 dup 0
	dw libload_v15_internal_len
libload_v15_internal_data:
	file '../obj/libload.bin'
	libload_v15_internal_len:=$-libload_v15_internal_data
end fs_file

fs_file libload_lll
	file '../obj/libload.bin'
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

fs_file msddrvce_lll
	file '../obj/msddrvce.bin'
end fs_file

fs_file srldrvce_lll
	file '../obj/srldrvce.bin'
end fs_file

fs_file usbdrvce_lll
	file '../obj/usbdrvce.bin'
end fs_file

; fs_file updater_exe
	; include 'fs/sbin/updater.asm'
; end fs_file

fs_file memedit_exe
	file '../obj/memedit.bin'
end fs_file

;-------------------------------------------------------------
; this needs to be at the end, and the address is expected to be reflected in osrt.asm
;-------------------------------------------------------------
db $04E000 - $ dup $FF

fs_file _osrt_lib_table
	dl _osrt_argv_so
	dl _osrt_numstr_so
	dl _osrt_mem_so
	dl _osrt_str_so
end fs_file

fs_file argv_so
	include 'fs/bin/argv.so.asm'
end fs_file

fs_file numstr_so
	include 'fs/bin/numstr.so.asm'
end fs_file

fs_file mem_so
	include 'fs/bin/mem.so.asm'
end fs_file

fs_file str_so
	include 'fs/bin/str.so.asm'
end fs_file

end fs_fs

