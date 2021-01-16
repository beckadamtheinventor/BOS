
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
	fs_entry dev_dir, "dev", "", f_readonly+f_system+f_subdir
	fs_entry etc_dir, "etc", "", f_readonly+f_system+f_subdir
	fs_entry home_dir, "home", "", f_subdir
	fs_entry lib_dir, "lib", "", f_readonly+f_system+f_subdir
	fs_entry usr_dir, "usr", "", f_readonly+f_system+f_subdir
	fs_entry autotest_dir, "autotest", "", f_readonly+f_system+f_subdir
end fs_dir

;"/bin/" directory
fs_dir bin_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry boot_exe, "boot", "exe", f_readonly+f_system
	fs_entry cat_exe, "cat", "exe", f_readonly+f_system
	fs_entry cd_exe, "cd", "exe", f_readonly+f_system
	fs_entry cmd_exe, "cmd","exe", f_readonly+f_system
	fs_entry clean_exe, "clean", "exe", f_readonly+f_system
	fs_entry cls_exe, "cls", "exe", f_readonly+f_system
	fs_entry dinitdev_exe, "dinitdev", "exe", f_readonly+f_system
	fs_entry explorer_exe, "explorer", "exe", f_readonly+f_system
	fs_entry fexplore_exe, "fexplore", "exe", f_readonly+f_system
	fs_entry files_exe, "files", "exe", f_readonly+f_system
	fs_entry info_exe, "info", "exe", f_readonly+f_system
	fs_entry initdev_exe, "initdev", "exe", f_readonly+f_system
	fs_entry ls_exe, "ls", "exe", f_readonly+f_system
	fs_entry memedit_exe, "memedit","exe", f_readonly+f_system
	fs_entry mkdir_exe, "mkdir", "exe", f_readonly+f_system
	fs_entry mount_exe, "mount", "exe", f_readonly+f_system
	fs_entry off_exe, "off","exe", f_readonly+f_system
	fs_entry rm_exe, "rm", "exe", f_readonly+f_system
	fs_entry uninstaller_exe, "uninstlr","exe", f_readonly+f_system
	fs_entry updater_exe, "updater", "exe", f_readonly+f_system
	fs_entry usbrun_exe, "usbrun","exe", f_readonly+f_system
	fs_entry usbsend_exe, "usbsend","exe", f_readonly+f_system
end fs_dir

;"/dev/" directory
fs_dir dev_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry cluster_map_file, "cmap", "dat", f_readonly+f_system
	fs_entry dev_lcd, "lcd", "", f_readonly+f_system+f_device
	fs_entry dev_null, "null", "", f_readonly+f_system+f_device
	fs_entry dev_mnt, "mnt", "", f_readonly+f_system+f_device
	fs_entry tivars_dir, "tivars", "", f_subdir
end fs_dir

;"/etc/" directory
fs_dir etc_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
end fs_dir

;"/lib/" directory
fs_dir lib_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry fatdrvce_lll, "FATDRVCE","LLL", f_readonly+f_system
	fs_entry fileioc_lll, "FILEIOC","LLL", f_readonly+f_system
	fs_entry fontlibc_lll, "FONTLIBC","LLL", f_readonly+f_system
	fs_entry graphx_lll, "GRAPHX","LLL", f_readonly+f_system
	fs_entry keypadc_lll, "KEYPADC", "LLL", f_readonly+f_system
	fs_entry srldrvce_lll, "SRLDRVCE","LLL", f_readonly+f_system
	fs_entry usbdrvce_lll, "USBDRVCE","LLL", f_readonly+f_system
	fs_entry libload_lll, "LibLoad", "LLL", f_readonly+f_system
end fs_dir

;"/home/" directory
fs_dir home_dir
	fs_entry root_dir, "..", "", f_subdir
	fs_entry user_home_dir, "user", "", f_subdir
end fs_dir

;"/home/user/" directory
fs_dir user_home_dir
	fs_entry home_dir, "..", "", f_subdir
	fs_entry user_settings_dat, "settings", "dat", 0
	db 16 dup 0
end fs_dir

;"/dev/tivars/" directory
fs_dir tivars_dir
	fs_entry dev_dir, "..", "", f_subdir+f_system
end fs_dir

;"/usr/" directory
fs_dir usr_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry usr_bin_dir, "bin", "", f_subdir
end fs_dir

;"/usr/bin/" directory
fs_dir usr_bin_dir
	fs_entry usr_dir, "..", "", f_subdir+f_system
end fs_dir

;"/autotest/" directory
fs_dir autotest_dir
	fs_entry root_dir, "..", "", f_subdir+f_system
	fs_entry test_exe, "test", "exe", f_readonly+f_system
end fs_dir

;-------------------------------------------------------------
;file data section
;-------------------------------------------------------------

fs_file cluster_map_file
	db 8192 dup $FF
end fs_file


fs_file dev_mnt
	db $C9, 1
	jp dev_mnt_init
	jp dev_mnt_deinit
	jp dev_mnt_get_address
	jp dev_mnt_read
	jp dev_mnt_write

dev_mnt_get_address:
	ld hl,bos.usb_sector_buffer
	ret

dev_mnt_init:
	ld hl,.data
	ld bc,.data_len
dev_mnt_run_in_ram:
	ld de,bos.driverExecRAM
	push de
	ldir
	ret
dev_mnt_init.data:
	file 'dev_mnt/init.bin'
dev_mnt_init.data_len:=$-dev_mnt_init.data

dev_mnt_deinit:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file 'dev_mnt/deinit.bin'
.data_len:=$-.data

dev_mnt_read:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file 'dev_mnt/read.bin'
.data_len:=$-.data

dev_mnt_write:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file 'dev_mnt/write.bin'
.data_len:=$-.data
end fs_file

fs_file dev_null
	db $C9, 1
	jp dev_null_retnull
	jp dev_null_retnull
	jp dev_null_get_location
	jp dev_null_read
	jp dev_null_write
	ret
dev_null_get_location:
	ld hl,$FF0000
	ret
dev_null_read:
	pop hl,de,bc
	push bc,de,hl
	ld hl,$FF0000
	ldir
	ret
dev_null_write:
	pop hl,de,bc
	push bc,de,hl
	ld hl,$FF0000
	add hl,bc
	ld bc,0
	ret
dev_null_retnull:
	or a,a
	sbc hl,hl
	ret
end fs_file

fs_file dev_lcd
	db $C9, 0
	jp dev_lcd_init
	jp dev_lcd_deinit
	jp dev_lcd_get_address
	jp dev_lcd_read
	jp dev_lcd_write
dev_lcd_write:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,ti.vRam
	add hl,bc
	ex hl,de
	jq dev_lcd_read.copy
dev_lcd_read:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,ti.vRam
	add hl,bc
.copy:
	ld bc,(ix+12)
	ldir
	pop ix
	ret
dev_lcd_get_address:
	ld hl,ti.vRam
	ret
dev_lcd_init:
	call dev_lcd_deinit
	ld	a,$27
	ld	($E30018),a
	ld	de,$E30200  ; address of mmio palette
	ld	b,e         ; b = 0
.loop:
	ld	a,b
	rrca
	xor	a,b
	and	a,224
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rla
	rla
	rla
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,.loop		; loop for 256 times to fill palette
	ret
dev_lcd_deinit:
	ld hl,ti.vRam
	ld de,ti.vRam+1
	ld (hl),l
	ld bc,320*240*2-1
	ldir
	ret
end fs_file

fs_file user_settings_dat
	db 16 dup 0
end fs_file


fs_file cmd_exe
	jq cmd_exe_main
	db "FEX",0
cmd_exe_main:
	ld hl,-6
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld hl,256
	push hl
	call bos.sys_Malloc
	pop bc
	ret c
	ld (ix-3),hl
	ld bc,256
	call bos._MemClear
enter_input_clear:
	ld hl,bos.InputBuffer
	ld bc,256
	call bos._MemClear
	jq enter_input
recall_last:
	ld hl,(ix-3)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,enter_input
	push hl
	call ti._strlen
	add hl,bc
	or a,a
	sbc hl,bc
	ex (sp),hl
	pop bc
	jq z,enter_input
	ld de,bos.InputBuffer
	ldir
enter_input:
	ld bc,255
	push bc
	ld bc,bos.InputBuffer
	push bc
	call bos.gui_InputNoClear
	or a,a
	jq z,.exit
	cp a,12
	jq z,recall_last
	cp a,10
	jq z,enter_input
	call ti._strlen
	ex (sp),hl
	pop bc
	push bc,hl
	inc bc
	ld de,(ix-3)
	ldir
	pop hl,bc,de
.get_args:
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
	push hl
	ld hl,(ix-6)
	add hl,bc
	or a,a
	sbc hl,bc
	push hl
	call nz,bos.sys_Free
	pop bc
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	pop hl
	ld (bos.ScrapMem),hl
	ld a,(bos.ScrapMem+2)
	or a,h
	or a,l
	jq z,enter_input_clear
	push hl
	call bos.gfx_BlitBuffer
	ld hl,str_ProgramFailedWithCode
	call bos.gui_Print
	pop hl
	call bos.gui_PrintInt
	call bos.gui_NewLine
	or a,$FF
	call bos.gfx_BlitBuffer
	jq enter_input_clear
.exit:
	pop bc,bc
	ld hl,(ix-3)
	push hl
	add hl,bc
	or a,a
	sbc hl,bc
	call nz,bos.sys_Free
	pop bc
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
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
str_ProgramFailedWithCode:
	db $9,$9,$9,$9,$9,"Error Code",0
str_exe_ext:
	db ".exe",0

str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",$A,0
end fs_file


fs_file boot_exe
	jq boot_main
	db "FEX",0
boot_main:
	call bos.fs_InitClusterMap
	call bos.sys_FlashUnlock
	ld de,boot_main
	ld hl,$FF0000
	ld bc,4
	call bos.sys_WriteFlash
	call bos.sys_FlashLock
.loop:
	call clean_main
	ld bc,$FF0000
	push bc
	ld bc,str_ExplorerExecutable
	push bc
	call bos.sys_ExecuteFile
	pop bc
	ld bc,1337
	or a,a
	sbc hl,bc
	pop bc
	ret z
	push bc
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
	dec bc
	ld a,c
	or a,b
	jq z,.return
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
	call bos.fs_AbsPath
	pop bc
.abspath:
	push hl
	call bos.fs_CheckDirExists
	pop hl
	jq c,.fail
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



fs_file ls_exe
	jq ls_main
	db "FEX",0
ls_main:
	ld hl,-3
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq nz,.non_null_dir
	ld hl,bos.current_working_dir
.non_null_dir:
	push hl
	call bos.gui_Print
	call bos.gui_NewLine
	or a,a
	sbc hl,hl
	ex (sp),hl
	ld bc,64
	push bc
	push hl
	ld bc,64*3
	push bc
	call bos.sys_Malloc
	pop bc
	push hl
	call bos.fs_DirList
	pop hl,bc,bc,bc
	ld (ix-6),hl
	jq c,.fail
	ld (ix-3),hl
.loop:
	ld hl,(ix-3)
	ld iy,(hl)
	inc hl
	inc hl
	inc hl
	ld (ix-3),hl
	ld a,(iy)
	or a,a
	jq z,.exit
	cp a,'.'
	jq z,.hidden
	bit bos.fd_hidden,(iy+$B) ;check if file is hidden
	jq z,.not_hidden
.hidden:
	ld a,$1F
	jq .set_cursor_color
.not_hidden:
	bit bos.fd_subdir,(iy+$B)
	jq z,.not_dir
	ld a,$07
	jq .set_cursor_color
.not_dir:
	ld a,$FF
.set_cursor_color:
	ld (bos.lcd_text_fg),a
	bit bos.fd_readonly,(iy+$B)
	jq z,.not_readonly
	db $3E ;ld a,... (0xAF happens to be a good color for this)
.not_readonly:
	xor a,a
	ld (bos.lcd_text_bg),a
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
	db $01
.fail:
	scf
	sbc hl,hl
	push af,hl
	ld hl,(ix-6)
	push hl
	add hl,bc
	or a,a
	sbc hl,bc
	call nz,bos.sys_Free
	pop bc
	pop hl,af
	ld sp,ix
	pop ix
	ret
.tab_str:
	db $9,$9,0
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
	jq updater_main
	db "FEX",0
updater_main:
	ld hl,str_UpdateProgram
	ld bc,str_UpdateFile
	push bc,hl
	call bos.sys_ExecuteFile
	pop bc,bc
	ret
str_UpdateProgram:
	db "/bin/usbrun.exe",0
str_UpdateFile:
	db "/BOSUPDTR.BIN",0
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

fs_file info_exe
	jq info_exe_main
	db "FEX",0
info_exe_main:
	pop bc,hl
	push hl,bc,hl
	call bos.fs_OpenFile
	pop bc
	ret c
	push hl
	ld hl,.string_filesize
	call bos.gui_Print
	call bos.fs_GetSectorAddress
	ex (sp),hl
	ld bc,$E
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	call bos.sys_HLToString
	ex hl,de
	call bos.gfx_PrintString
	pop hl
	ld a,(hl)
	cp a,$18
	jq z,.skip2
	cp a,$C3
	jq z,.skip4
	cp a,$80
	jq nc,.binary
	cp a,$20
	jr nc,.text
.binary:
	ld hl,.string_bin
	jq .print_type
.text:
	ld hl,.string_text
	jq .print_type
.fex:
	ld hl,.string_fex
	jq .print_type
.rex:
	ld hl,.string_rex
	jq .print_type
.skip4:
	inc hl
	inc hl
.skip2:
	inc hl
	inc hl
	ld de,(hl)
	db $21, "FEX"
	or a,a
	sbc hl,de
	jq z,.fex
	db $21, "REX"
	or a,a
	sbc hl,de
	jq z,.rex
	jq .binary
.print_type:
	push hl
	call bos.gui_NewLine
	pop hl
	call bos.gui_Print
	call bos.gui_NewLine
	or a,a
	sbc hl,hl
	ret
.string_filesize:
	db "File Size: ",0
.string_bin:
	db "Binary file",0
.string_text:
	db "Text file",0
.string_fex:
	db "Flash EXecutable",0
.string_rex:
	db "RAM EXecutable",0
end fs_file

fs_file rm_exe
	jq rm_main
	db "FEX",0
rm_main:
	pop bc,hl
	push hl,bc
	push hl
	call bos.fs_OpenFile
	ex (sp),hl
	pop iy
	bit f_readonly, (iy+$B)
	jq nz,.fail
	push iy
	call bos.fs_DeleteFile
	pop bc
	xor a,a
	sbc hl,hl
	ret
.fail:
	ld hl,.string_readonly
	call bos.gui_Print
	ld hl,1
	ret
.string_readonly:
	db $9,"Read only file cannot be removed.",$A,0
end fs_file


fs_file mkdir_exe
	jq mkdir_main
	db "FEX",0
mkdir_main:
	ld hl,-19
	call ti._frameset
	ld hl,(ix+6)
	push hl
	call bos.fs_AbsPath
	ex (sp),hl
	call bos.fs_ParentDir
	ld (ix-3),hl
	inc hl
	ld a,(hl)
	dec hl
	or a,a
	call nz,bos.fs_OpenFile
	jq nc,.fail
.create:
	pop bc
	ld c,f_subdir
	ld de,64
	push de,bc,hl
	call bos.fs_CreateFile
	jq c,.fail
	pop bc,bc,bc

	ld bc,0
	push bc,hl
	ld c,1
	push bc
	ld c,16
	push bc
	lea de,ix-19
	push de
	ld hl,.path_back_entry
	ld c,11
	ldir
	ld hl,(ix-3) ;open the parent directory
	push hl
	call bos.fs_OpenFile
	jq c,.fail
	pop bc
	xor a,a
	ld (ix + $C - 19), hl
	ld (ix + $E - 19), a
	ld (ix + $F - 19), a
	call bos.fs_Write ; point to the parent dir in the created dir
	jq c,.fail
	pop bc,bc,bc,hl,bc
	ld bc,16
	push bc
	ld e,1
	push de
	push bc
	ld bc,$FF0000
	push bc
	call bos.fs_Write
	jq c,.fail
	pop bc,bc,bc,hl,bc
	ld c,16
	push bc,hl
	ld c,1
	push bc
	ld c,16
	push bc
	ld de,$FF0000
	push de
	call bos.fs_Write ;write the end-of-directory marker in created dir
	jq c,.fail
	ld hl,(ix-3)
	push hl
	call bos.fs_OpenFile ;open the parent dir
	jq c,.fail
	pop bc
	push hl
	ld bc,16
	xor a,a
.find_eod_loop:
	or a,(hl)
	jq z,.write_created_entry
	add hl,bc
	jq .find_eod_loop
.write_created_entry:
	pop bc
	or a,a
	sbc hl,bc
	pop bc,bc,bc,de,bc

	push hl,de
	ld c,1
	push bc
	ld c,16
	push bc
	ld hl,(ix+6)
	push hl
	call bos.fs_GetPathLastName
	ex (sp),hl
	pea ix-19
	call bos.fs_StrToFileEntry
	pop hl
	ex (sp),hl
	call bos.fs_Write
	jq c,.fail
	pop bc,bc,bc,bc,bc

	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.fail:
	ld hl,.string_fileexists
	call bos.gui_Print
	ld hl,1
	ld sp,ix
	pop ix
	ret
.string_fileexists:
	db $9,"File/Dir already exists.",$A,0
.path_back_entry:
	db "..         ",$10
end fs_file


fs_file files_exe
	file '../obj/files.bin'
end fs_file


fs_file mount_exe
	jr mount_exe_main
	db "FEX",0
mount_exe_main:
	ld bc,.dev_mnt
	push bc
	call bos.sys_InitDevice
	pop bc
	push hl
	call bos.sys_DeinitDevice
	pop bc
	ret
.dev_mnt:
	db "/dev/mnt",0
end fs_file


fs_file initdev_exe
	jr initdev_exe_main
	db "FEX",0
initdev_exe_main:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	ret z
	push hl
	call bos.sys_InitDevice
	pop bc
	ret
end fs_file


fs_file dinitdev_exe
	jr dinitdev_exe_main
	db "FEX",0
dinitdev_exe_main:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	ret z
	push hl
	call bos.sys_DeinitDevice
	pop bc
	ret
end fs_file


; -- tester program --
; should be removed upon release

fs_file	test_exe
	jr test_exe_main
	db "FEX",0
test_exe_main:
	ld (bos.SaveSP),sp
	ld hl,.tester_string
	call bos.gui_Print
	ld hl,.testing_file_creation
	call bos.gui_Print
	ld hl,.dir_to_create
	ld c,f_subdir
	push bc,hl
	call bos.fs_OpenFile
	push hl
	call nc,bos.fs_DeleteFile
	pop bc
	call bos.fs_CreateFile
	pop de,bc
	call z,.fail
	ld bc,0
	push bc,hl
	ld hl,.testing_file_writing
	call bos.gui_Print
	ld bc,1
	push bc
	ld c,16
	push bc
	call bos.sys_Malloc
	jq c,.malloc_fail
	ex hl,de
	ld hl,.path_back_entry
	pop bc
	push bc,de
	ldir
	call bos.fs_Write
	pop bc,bc,bc,bc,bc

	ld hl,.file_to_create
	ld c,0
	push bc,hl
	call bos.fs_OpenFile
	push hl
	call nc,bos.fs_DeleteFile
	pop bc
	call bos.fs_CreateFile
	pop de,bc
	call z,.fail
	ld sp,(bos.SaveSP)
	ld hl,.tests_finished_string
	jp bos.gui_Print
.malloc_fail:
	ld sp,(bos.SaveSP)
	ld hl,.malloc_fail_string
	jp bos.gui_Print
.fail:
	ld hl,.test_failed_string
	jp bos.gui_Print
.tester_string:
	db "--BOS Autotester--",$A
	db $9,"Testing...",$A,0
.tests_finished_string:
	db "Tests complete",$A,0
.testing_file_creation:
	db "File deletion and creation",$A,0
.testing_file_writing:
	db "File writing",$A,0
.test_failed_string:
	db $9,"Test failed.",$A,0
.malloc_fail_string:
	db "Failed to malloc!",$A,0
.path_back_entry:
	db "..         ",f_subdir,0,0,0,0
.dir_to_create:
	db "/home/tester/",0
.file_to_create:
	db "/home/tester/test.txt",0
end fs_file

end fs_fs


