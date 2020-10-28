
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
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_readonly+f_system+f_subdir
	fs_entry man_dir, "man", "", f_readonly+f_system+f_subdir
	fs_entry root_user_dir, "root", "", f_subdir+f_system
	db 16 dup 0
end fs_file

;"/bin/" directory
fs_file bin_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry boot_exe, "boot", "EXE", f_readonly+f_system
	fs_entry cat_exe, "cat", "EXE", f_readonly+f_system
	fs_entry cd_exe, "cd", "EXE", f_readonly+f_system
	fs_entry cmd_exe, "cmd","EXE", f_readonly+f_system
	fs_entry clean_exe, "clean", "EXE", f_readonly+f_system
	fs_entry cls_exe, "cls", "EXE", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "EXE", f_readonly+f_system
	fs_entry fexplore_exe, "fexplore", "EXE", f_readonly+f_system
	fs_entry help_exe, "help", "EXE", f_readonly+f_system
	fs_entry ls_exe, "ls", "EXE", f_readonly+f_system
	fs_entry man_exe, "man", "EXE", f_readonly+f_system
	fs_entry uninstaller_exe, "uninstlr","EXE", f_readonly+f_system
	fs_entry updater_exe, "updater", "EXE", f_readonly+f_system
	fs_entry memedit_exe, "memedit","EXE", f_readonly+f_system
	fs_entry off_exe, "off","EXE", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun","EXE", f_readonly+f_system
	fs_entry usbsend_exe, "usbsend","EXE", f_readonly+f_system
	db 16 dup 0
end fs_file

;"/lib/" directory
fs_file lib_dir
	fs_entry root_dir, "..", "", f_subdir
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
	fs_entry root_dir, "..", "", f_subdir
	fs_entry readme_man, "README", "MAN", f_readonly+f_system
	db 16 dup 0
end fs_file

fs_file root_user_dir
	fs_entry root_dir, "..", "", f_subdir
	db 16 dup 0
end fs_file

fs_file home_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry user_home_dir, "user", "", f_subdir
	db 16 dup 0
end fs_file

fs_file user_home_dir
	fs_entry home_dir, "..", "", f_subdir
	fs_entry user_settings_dat, "settings", "dat", 0
	db 16 dup 0
end fs_file

;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file user_settings_dat
	db 0
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
	call bos.sys_ExecuteFile
	pop bc,bc
	ld bc,enter_input
	push bc
	jq c,.fail
	ld (bos.ScrapMem),hl
	ld a,(bos.ScrapMem+2)
	or a,h
	or a,l
	ret z
	push hl
	call bos.gfx_BlitBuffer
	pop hl
	call bos.gui_PrintInt
	call bos.gui_NewLine
	or a,$FF
	jp bos.gfx_BlitBuffer
.fail:
	pop bc,bc
	ld hl,str_CouldNotLocateExecutable
	call bos.gui_Print
	jq enter_input
.exit:
	pop bc,bc
	ret
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
	db "cmd",0
str_ExplorerExecutable:
	db "explorer",0
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
	push ix
	push hl
	call bos.fs_CheckDirExists
	pop hl
	jq c,.fail
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jq z,.abs_path
	push hl
	ld hl,bos.current_working_dir
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	ex (sp),hl
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	pop de
	ldir
	jq .return
.abs_path:
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld de,bos.current_working_dir
	ldir
	xor a,a
	ld (de),a
.return:
	pop ix
	xor a,a
	sbc hl,hl
	ret
.fail:
	pop ix
	ld hl,str_DirDoesNotExist
	call bos.gui_Print
	ld hl,-2
	ret
.help:
	ld hl,str_HelpDoc
	call bos.gui_Print
	or a,a
	sbc hl,hl
	ret
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
	push ix
	push hl
	pop ix
.loop:
	ld a,(ix)
	or a,a
	jq z,.exit
	bit bos.fd_hidden,(ix+$B) ;check if file is hidden
	jq z,.not_hidden
	ld a,$1F
	jq .set_cursor_color
.not_hidden:
	ld a,$FF
.set_cursor_color:
	ld (bos.lcd_text_fg),a
	ld hl,bos.fsOP6+1
	push ix,hl
	call bos.fs_CopyFileName
	pop hl,ix
	dec hl
	ld (hl),$9
	call bos.gui_Print
	lea ix,ix+16
	jq .loop
.exit:
	pop ix
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

;fs_file "USBLS","EXE", f_readonly+f_system
;	file "../obj/usbls.bin"
;end fs_file
fs_file usbsend_exe
	file "../obj/usbsend.bin"
end fs_file



end fs_fs
