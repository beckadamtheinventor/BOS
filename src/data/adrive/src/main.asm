
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
fs_file root_dir
	fs_entry bin_dir, "bin", "", f_readonly+f_system+f_subdir
	fs_entry dev_dir, "dev", "", f_readonly+f_system+f_subdir
	fs_entry etc_dir, "etc", "", f_readonly+f_system+f_subdir
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_readonly+f_system+f_subdir
	fs_entry man_dir, "man", "", f_readonly+f_system+f_subdir
	fs_entry root_user_dir, "root", "", f_subdir+f_system
	fs_entry test_dir, "test", "", f_subdir+f_system
	db 16 dup 0
end fs_file

;"/bin/" directory
fs_file bin_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry boot_exe, "boot", "exe", f_readonly+f_system
	fs_entry cat_exe, "cat", "exe", f_readonly+f_system
	fs_entry cd_exe, "cd", "exe", f_readonly+f_system
	fs_entry cmd_exe, "cmd","exe", f_readonly+f_system
	fs_entry clean_exe, "clean", "exe", f_readonly+f_system
	fs_entry cls_exe, "cls", "exe", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "exe", f_readonly+f_system
	fs_entry fexplore_exe, "fexplore", "exe", f_readonly+f_system
	fs_entry help_exe, "help", "exe", f_readonly+f_system
	fs_entry ls_exe, "ls", "exe", f_readonly+f_system
	fs_entry man_exe, "man", "exe", f_readonly+f_system
	fs_entry uninstaller_exe, "uninstlr","exe", f_readonly+f_system
	fs_entry updater_exe, "updater", "exe", f_readonly+f_system
	fs_entry memedit_exe, "memedit","exe", f_readonly+f_system
	fs_entry off_exe, "off","exe", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun","exe", f_readonly+f_system
	fs_entry usbsend_exe, "usbsend","exe", f_readonly+f_system
	db 16 dup 0
end fs_file

;"/dev/" directory
fs_file dev_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry cluster_map_file, "cmap", "dat", f_readonly+f_system
	db 16 dup 0
end fs_file

;"/etc/" directory
fs_file etc_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	db 16 dup 0
end fs_file

;"/test/" directory
fs_file test_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry tester_exe, "tester", "exe", f_system+f_readonly
	db 16 dup 0
end fs_file

;"/lib/" directory
fs_file lib_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry fatdrvce_lll, "FATDRVCE","LLL", f_readonly+f_system
	fs_entry fileioc_lll, "FILEIOC","LLL", f_readonly+f_system
	fs_entry graphx_lll, "GRAPHX","LLL", f_readonly+f_system
	fs_entry srldrvce_lll, "SRLDRVCE","LLL", f_readonly+f_system
	fs_entry usbdrvce_lll, "USBDRVCE","LLL", f_readonly+f_system
	fs_entry libload_lll, "LibLoad", "LLL", f_readonly+f_system
	db 16 dup 0
end fs_file

;"/man/" directory
fs_file man_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry readme_man, "README", "MAN", f_readonly+f_system
	db 16 dup 0
end fs_file


;"/root/" directory
fs_file root_user_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	db 16 dup 0
end fs_file

;"/home/" directory
fs_file home_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry user_home_dir, "user", "", f_subdir
	db 16 dup 0
end fs_file

;"/home/user/" directory
fs_file user_home_dir
	fs_entry home_dir, "..", "", f_subdir
	fs_entry user_settings_dat, "settings", "dat", 0
	db 16 dup 0
end fs_file

;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file cluster_map_file
	db 8192 dup $FF
end fs_file

fs_file user_settings_dat
	db 16 dup 0
end fs_file

fs_file tester_exe
	jq tester_exe_main
	db "FEX",0
tester_exe_main:
	ld hl,.file_to_write
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	ld bc,1024
	push hl,bc
	call bos.fs_SetSize
	pop bc,hl
	ld bc,0
	push bc,hl
	ld c,1
	push bc
	ld c,.file_to_write_len
	push bc
	ld bc,.file_to_write
	push bc
	call bos.fs_Write
	pop bc,bc,bc
	ld bc,.file_to_write_len
	push bc
	call bos.sys_Malloc
	pop bc
	pop de,bc
	jq c,.fail
	ld bc,0
	push bc,de
	ld c,1
	push bc
	ld c,.file_to_write_len
	push bc,hl
	call bos.fs_Read
	pop hl,bc,bc,bc,bc
	call bos.gui_Print
	call bos.gui_NewLine
	xor a,a
.fail:
	sbc hl,hl
	ret
.file_to_write:
	db "/home/user/settings.dat",0
.file_to_write_len := $ - .file_to_write

end fs_file

fs_file cmd_exe
	jq enter_input
	db "FEX",0
enter_input:
	ld bc,255
	push bc
	ld bc,bos.InputBuffer
	push bc
	call bos.gui_Input
	or a,a
	jq z,.exit
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	ld a,' '
	cpir
	jq nz,.noargs
	dec hl
	ld (hl),0 ;replace the space with null so the file is easier to open
	inc hl ;bypass the space lol
.noargs:
	ex (sp),hl ;args
	push hl ;path
	call bos.fs_OpenFile
	jq c,.system_exe
.execute:
	call bos.sys_ExecuteFile
	pop bc,bc
	ld (bos.ScrapMem),hl
	ld a,(bos.ScrapMem+2)
	or a,h
	or a,l
	jq z,enter_input
	push hl
	call bos.gfx_BlitBuffer
	pop hl
	call bos.gui_PrintInt
	call bos.gui_NewLine
	or a,$FF
	call bos.gfx_BlitBuffer
	jq enter_input
.exit:
	pop bc,bc
	ret
.system_exe:
	call ti._strlen
	ex (sp),hl
	pop bc
	push bc,hl
	ld hl,5+str_system_drive.len
	add hl,bc
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl,bc
	jq c,.exit
	push de,bc,hl
	ld hl,str_system_drive
	ld bc,str_system_drive.len
	ldir
	pop hl,bc
	ldir
	ld hl,str_exe_ext
	ld bc,5
	ldir
	call bos.fs_OpenFile
	jq nc,.execute
.fail:
	pop bc,bc
	ld hl,str_CouldNotLocateExecutable
	call bos.gui_Print
	jq enter_input
str_system_drive:
	db "/bin/"
.len:=$-.
str_exe_ext:
	db ".exe",0

str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",$A,0
end fs_file


fs_file boot_exe
	jq boot_main
	db "FEX",0
boot_main:
	;ld hl,boot_script
	;push hl
	;call bsh_start
	;pop bc
	;ret
;boot_script:
	;db "CLS",0
	;db "CLEAN",0
	;db "EXPLORER",0
	;db "CLS",0
	;db "CMD",0
	;db "CLS",0
	;db "ASM",0
	;pop bc,bc,bc
	;jq boot_main
.loop:
	call clean_main
	call cls_main
	ld bc,$FF0000
	push bc
	ld bc,str_ExplorerExecutable
	push bc
	call bos.sys_ExecuteFile
	pop bc
	call cls_main
	ld bc,str_CmdExecutable
	push bc
	call bos.sys_ExecuteFile
	pop bc
	pop bc
	jq .loop
str_CmdExecutable:
	db "/bin/cmd.exe",0
str_ExplorerExecutable:
	db "/bin/explorer.exe",0
end fs_file

fs_file cat_exe
	jq cat_main
	db "FEX",0
cat_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.help
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	push iy
	push hl
	pop iy
	ld hl,(iy+$E) ;file length
	ld de,(iy+$C)
	or a,a
	sbc hl,de
	call bos.fs_MultByBytesPerSector
	ld de,1024
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.file_too_large
	ld hl,(iy+$C)
	call bos.fs_GetSectorAddress
	pop iy
	jq .print
.file_too_large:
	pop iy
	ld hl,str_FileTooLarge
	jq .print
.help:
	ld hl,str_CatHelp
.print:
	call bos.gui_Print
	xor a,a
	sbc hl,hl
	ret
.fail:
	scf
	sbc hl,hl
	ret
str_FileTooLarge:
	db $9,"File too large to display at this time.",$A,0
str_CatHelp:
	db $9,"Usage: CAT [file]",$A,0
end fs_file


fs_file cd_exe
	jq cd_main
	db "FEX",0
cd_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.help
	cp a,'/'
	jq z,.abspath
	cp a,'.'
	jq nz,.not_dot
	inc hl
	cp a,(hl)
	jq nz,.return
	ld hl,bos.current_working_dir
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	add hl,bc
	ld a,'/'
	cpdr
	dec hl
	cpdr
	inc hl
	ld (hl),0
	pop hl
	ld (hl),a
	jq .return
.not_dot:
	push hl
	call bos.fs_CheckDirExists
	pop hl
	jq c,.fail
	push hl
	call bos.fs_AbsPath
	pop bc
.abspath:
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld de,bos.current_working_dir
	ldir
	ex hl,de
	dec hl
	ld a,'/'
	cp a,(hl)
	inc hl
	jq z,.dont_put_fwd
	ld (hl),a
	inc hl
.dont_put_fwd:
	ld (hl),0
.return:
	xor a,a
	sbc hl,hl
	ret
.fail:
	ld hl,str_DirDoesNotExist
	call bos.gui_Print
	call bos.gui_NewLine
	ld hl,-2
	ret
.help:
	ld hl,str_HelpDoc
	call bos.gui_Print
	jq .return
str_DirDoesNotExist:
	db $9,"Directory does not exist.",$A,0
str_HelpDoc:
	db $9,"Usage: CD [dir]",$A,0
end fs_file


fs_file clean_exe
	jq clean_main
	db "FEX",0
clean_main:
	call bos.sys_FreeAll
	xor a,a
	sbc hl,hl
	ret
end fs_file


fs_file cls_exe
	jq cls_main
	db "FEX",0
cls_main:
	ld hl,bos.current_working_dir
	call bos.gui_DrawConsoleWindow
	ld hl,str_Prompt
	call bos.gfx_PrintString
	call bos.gui_NewLine
	xor a,a
	sbc hl,hl
	ret
str_Prompt:
	db ">",$A,0
end fs_file


fs_file explorer_exe
	file '../obj/explorer.bin'
end fs_file


fs_file fexplore_exe
	file '../obj/fexplore.bin'
end fs_file


fs_file help_exe
	jq help_main
	db "FEX",0
help_main:
	ld hl,.readme_file
	push hl
	call cat_main
	pop bc
	ret
.readme_file:
	db "/man/README.MAN",0
end fs_file


fs_file ls_exe
	jq ls_main
	db "FEX",0
ls_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq nz,.non_null_dir
	ld hl,bos.current_working_dir
.non_null_dir:
	push hl
	call bos.gui_Print
	call bos.gui_NewLine
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	push hl
	pop iy
.loop:
	ld a,(iy)
	or a,a
	jq z,.exit
	bit bos.fd_hidden,(iy+$B) ;check if file is hidden
	jq z,.not_hidden
	ld a,$1F
	jq .set_cursor_color
.not_hidden:
	ld a,$FF
.set_cursor_color:
	ld (bos.lcd_text_fg),a
	ld hl,bos.fsOP6+1
	push iy,hl
	call bos.fs_CopyFileName
	pop hl,iy
	dec hl
	ld (hl),$9
	call bos.gui_Print
	call bos.gui_NewLine
	lea iy,iy+16
	jq .loop
.exit:
.exit_nopop:
	xor a,a
	sbc hl,hl
	ret
.fail:
	scf
	sbc hl,hl
	ret
.tab_str:
	db $9,$9,0
end fs_file


fs_file man_exe
	jq man_main
	db "FEX",0
man_main:
	pop bc
	pop hl
	push hl
	push bc
	and a,(hl)
	jq z,.info
	push hl
	call ti._strlen
	ld bc,str_man_dir.len+5
	add hl,bc
	push hl
	call bos.sys_Malloc
	pop bc
	ex hl,de
	pop hl ;argument
	push de
	push hl
	ld bc,str_man_dir.len
	ld hl,str_man_dir
	ldir          ; copy in manual directory
	call ti._strlen
	ex (sp),hl
	pop bc
	ldir          ; copy in manual name
	ld hl,man_extension
	ld c,5
	ldir          ; copy in manual extension and null byte
	call bos.fs_OpenFile  ;try to open file
	pop de
	jq c,.not_found
	ld bc,0
.display_loop:
	push bc,de,hl
	ex hl,de
	call bos.gui_DrawConsoleWindow
	call bos.gui_NewLine
	pop hl,de,bc
	push de,bc,hl
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	call bos.fs_GetSectorAddress
	pop de,bc,iy
;	jq c,.eof
	push iy,de,bc
	call bos.gui_Print
	call bos.sys_WaitKeyCycle
	pop bc,hl,de
	cp a,4
	jq z,.scroll_up
	inc bc
	cp a,15
	jq nz,.display_loop
.eof:
	push bc,de,hl
	ld hl,man_EndOfFileReached
	call bos.gui_Print
	call bos.sys_WaitKeyCycle
	pop hl,de,bc
	cp a,4
	jq z,.scroll_up
	cp a,9
	jq z,.exit
	cp a,15
	jq nz,.display_loop
.exit:
	xor a,a
	sbc hl,hl
	ret
.scroll_up:
	ld (bos.ScrapMem),bc
	ld a,(bos.ScrapMem+2)
	or a,b
	or a,c
	jq z,.display_loop
	dec bc
	jq .display_loop
.not_found:
	ld hl,man_NotFound
	call bos.gui_Print
	call bos.gui_NewLine
	scf
	sbc hl,hl
	ret
.info:
	ld hl,str_ManInfo
	call bos.gui_Print
	xor a,a
	sbc hl,hl
	ret
str_ManInfo:
	db $9,"Usage: MAN [app]",$A,0
man_EndOfFileReached:
	db $9,"--EOF REACHED--",$A
man_NotFound:
	db $9,"No matching manual found.",0
str_man_dir:
	db "/man/"
str_man_dir.len:=$-.
man_extension:
	db ".MAN",0
end fs_file


fs_file readme_man
	db $9,"--BOSos Help Doc--",$A
	db "cat",$A,$9,"Display the contents of a file.",$A
	db "cd",$A,$9,"Change Directory. Navigate to an absolute or relative path.",$A
	db "clean",$A,$9,"Clean up malloc'd memory, not including program memory.",$A
	db "cls",$A,$9,"CLear Screen. Wipes the terminal history.",$A
	db "explorer",$A,$9,"Open GUI interface.",$A
	db "fexplore", $A,$9,""
	db "help",$A,$9,"display this document",$A
	db "ls",$A,$9,"LiSt directory. List the current directory or a given directory.",$A
	db "man",$A,$9,"Display MANual for a given executable.",$A
	db 0
end fs_file

fs_file fatdrvce_lll
	file '../obj/fatdrvce.bin'
end fs_file

fs_file fileioc_lll
	file '../obj/fileioc.bin'
end fs_file

fs_file graphx_lll
	file '../obj/graphx.bin'
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
	jq uninstall_main
	db "FEX",0
uninstall_main:
	ld hl,.are_you_sure
	call bos.gui_DrawConsoleWindow
	call bos.sys_WaitKey
	cp a,9
	ret nz
	call bos.sys_FlashUnlock
	ld a,$02
	call bos.sys_EraseFlashSector
	rst $08
.are_you_sure:
	db "Are you sure?",$A
	db "This will erase BOS and all user data currently in the filesystem.",$A
	db "Press [enter] to confirm",$A,0
end fs_file


fs_file updater_exe
	file '../obj/updater.bin'
end fs_file

fs_file memedit_exe
	file '../obj/memedit.bin'
end fs_file


fs_file off_exe
	jq turn_off_main
	db "FEX",0
turn_off_main:
	call ti.boot.TurnOffHardware
	di
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ld l,ti.intAck
	set ti.bIntOn,(hl)
	ei
	halt
	nop
	nop
	jp ti.boot.InitializeHardware
end fs_file


fs_file usbrun_exe
	file "../obj/usbrun.bin"
end fs_file

;fs_file "USBLS","exe", f_readonly+f_system
;	file "../obj/usbls.bin"
;end fs_file

fs_file usbsend_exe
	file "../obj/usbsend.bin"
end fs_file

fs_file tedit_exe
	file "../obj/tedit.bin"
end fs_file

end fs_fs
