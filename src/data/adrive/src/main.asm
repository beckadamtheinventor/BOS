
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'

org $040800
fs_fs 1, 2 ;filesystem with 1 sector per cluster, and 2 sectors per FAT


fs_file "CMD","EXE", f_readonly+f_system
	jr enter_input
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
	jr nz,.noargs
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
	jr c,.fail
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


str_ExplorerExecutable:
	db "EXPLORER",0
str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",$A,0
end fs_file

fs_file "APRG","EXE", f_readonly+f_system
	jr aprg_main
	db "FEX",0
aprg_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,.fail
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.fail ;file not found
	ld bc,$1C ;get file length
	add hl,bc
	ld de,(hl)
	or a,a
	sbc hl,bc
	ld bc,0
	push de,bc,hl
	call bos.fs_GetClusterPtr
	pop bc,bc,bc
	jq c,.fail ;file first cluster could not be located
	ld a,(hl)
	cp a,$EF
	jr nz,.fail ;not a valid executable
	inc hl
	ld a,(hl)
	cp a,$7B
	jr nz,.fail ;not a valid executable
	dec hl
	ld (bos.asm_prgm_size),bc
	push hl,bc
	push bc
	pop hl
	call bos._EnoughMem
	pop bc,hl
	jq c,.fail ;not enough memory
;copy program into UserMem
	push hl
	ld hl,ti.userMem
	push hl
	add hl,bc
	ld (bos.top_of_UserMem),hl
	pop de,hl
	inc hl
	inc hl
	push de
	ldir
	ret ;jump to userMem
.fail:
	scf
	sbc hl,hl
	ret
end fs_file

fs_file "BOOT", "EXE", f_readonly+f_system
	jr boot_main
	db "FEX",0
boot_main:
	ld hl,boot_script
	push hl
	call bsh_start
	pop bc
	ret
boot_script:
	db "CLS",0
	db "CLEAN",0
	db "EXPLORER",0
	db "CLS",0
	db "CMD",0
	db "CLS",0
	db "ASM",0
	pop bc,bc,bc
	jq boot_main
end fs_file


fs_file "BSH", "EXE", f_readonly+f_system
	jr bsh_start
	db "FEX",0
bsh_start:
	pop bc
	pop hl
	push hl
	push bc
bsh_main:
	ld ix,bsh_commands-6
.loop:
	push hl
	call bos.sys_GetKey
	pop hl
	cp a,53
	jq z,.keyboard_interrupt
	lea ix,ix+6
	push hl
	ld hl,(ix)
	ld a,(hl)
	or a,a
	jr z,.runexec
	push hl
	call ti._strlen
	pop bc
	ex (sp),hl
	push bc
	push hl
	call ti._strncmp
	add hl,bc
	or a,a
	sbc hl,bc
	pop hl
	pop de
	pop bc
	jq nz,.loop
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	inc hl
	push hl
	ld hl,(ix+3)
	call .jphl  ;jump to command handler subroutine
	pop hl
	jq .loop
.keyboard_interrupt:
	ld hl,str_KeyboardInterrupt
	call bos.gui_Print
	xor a,a
	ret
.runexec:
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	add hl,bc
	push hl
	or a,a
	sbc hl,bc
	ld a,' '
	cpir
	pop bc,de
	push bc,hl,de
	call bos.sys_ExecuteFile
	pop bc,bc,hl
	inc hl
	jq bsh_main

str_KeyboardInterrupt:
	db $9,"Program execution stopped.",$A,0
bsh_commands:
	dl str_Return, handler_Return
	dl str_Asm, handler_Asm
	dl $FF0000
str_Asm:
	db "ASM",0
handler_Asm:
	pop bc
	pop hl
bsh_main.jphl:
	jp (hl)
str_Return:
	db "RETURN",0
handler_Return:
	pop bc
	xor a,a
	ret
end fs_file


fs_file "CAT", "EXE", f_readonly+f_system
	jr cat_main
	db "FEX",0
cat_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jr z,.help
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.fail
	push iy
	push hl
	pop iy
	ld hl,(iy+$1C) ;file length
	ld de,1024
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.file_too_large
	ld bc,0
	push bc,iy
	call bos.fs_GetClusterPtr
	pop bc,bc,iy
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


fs_file "CD", "EXE", f_readonly+f_system
	jr cd_main
	db "FEX",0
cd_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jr z,.help
	push ix
	push hl
	call bos.fs_CheckDirExists
	pop hl
	jr c,.fail
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jr z,.abs_path
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


fs_file "CLEAN", "EXE", f_readonly+f_system
	jr clean_main
	db "FEX",0
clean_main:
	call bos.sys_FreeAll
	xor a,a
	sbc hl,hl
	ret
end fs_file


fs_file "CLS", "EXE", f_readonly+f_system
	jr cls_main
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


fs_file "EXPLORER", "EXE", f_readonly+f_system
	file '../obj/explorer.bin'
end fs_file


fs_file "FEXPLORE", "EXE", f_readonly+f_system
	file '../obj/fexplore.bin'
end fs_file


fs_file "HELP", "EXE", f_readonly+f_system
	jr help_main
	db "FEX",0
help_main:
	ld hl,.readme_file
	push hl
	call cat_main
	pop bc
	ret
.readme_file:
	db "A:/README.MAN",0
end fs_file


fs_file "LS", "EXE", f_readonly+f_system
	jr ls_main
	db "FEX",0
ls_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jr nz,.non_null_dir
	ld hl,bos.current_working_dir
.non_null_dir:
	push hl
	call bos.gui_Print
	call bos.gui_NewLine
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	ld a,(hl)
	or a,a
	jr z,.exit_nopop
	push ix
	push hl
	pop ix
.loop:
	ld hl,bos.fsOP6+1
	push ix,hl
	call bos.fs_CopyFileName
	pop hl,ix
	dec hl
	ld (hl),$9
	call bos.gui_Print
	call bos.gui_NewLine
	lea ix,ix+32
	ld a,(ix)
	or a,a
	jr nz,.loop
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
end fs_file


fs_file "MAN", "EXE", f_readonly+f_system
	jr man_main
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
	ld bc,man_dir.len+5
	add hl,bc
	push hl
	call bos.sys_Malloc
	pop bc
	ex hl,de
	pop hl ;argument
	push de
	push hl
	ld bc,man_dir.len
	ld hl,man_dir
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
	call bos.fs_GetClusterPtr
	pop de,bc,iy
	jq c,.eof
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
man_dir:
	db "A:/"
man_dir.len:=$-.
man_extension:
	db ".MAN",0
end fs_file




fs_file "README", "MAN", f_readonly+f_system
	db $9,"--BOSos Help Doc--",$A
	db "CAT",$A,$9,"Display the contents of a file.",$A
	db "CD",$A,$9,"Change Directory. Navigate to an absolute or relative path.",$A
	db "CLEAN",$A,$9,"Clean up malloc'd memory, not including program memory.",$A
	db "CLS",$A,$9,"CLear Screen. Wipes the terminal history.",$A
	db "EXPLORER",$A,$9,"Open GUI interface.",$A
	db "HELP",$A,$9,"display this document",$A
	db "LS",$A,$9,"LiSt directory. List the current directory or a given directory.",$A
	db "MAN",$A,$9,"Display MANual for a given executable.",$A
	db 0
end fs_file


fs_file "FATDRVCE","v21", f_readonly+f_system
	file '../obj/fatdrvce.bin'
end fs_file

fs_file "FILEIOC","v21", f_readonly+f_system
	file '../obj/fileioc.bin'
end fs_file

fs_file "GRAPHX","v21", f_readonly+f_system
	file '../obj/graphx.bin'
end fs_file

fs_file "SRLDRVCE","v21", f_readonly+f_system
	file '../obj/srldrvce.bin'
end fs_file

fs_file "USBDRVCE","v21", f_readonly+f_system
	file '../obj/usbdrvce.bin'
end fs_file

fs_file "LibLoad", "v21", f_readonly+f_system
	file '../obj/bos_libload.bin'
end fs_file

fs_file "UNINSTLR","EXE", f_readonly+f_system
	jr uninstall_main
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


fs_file "MEMEDIT","EXE", f_readonly+f_system
	file '../obj/memedit.bin'
end fs_file

fs_file "MKFILE","EXE", f_readonly+f_system
	jr mkfile_main
	db "FEX",0
mkfile_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,mkfile_info
	push hl
	call bos.sys_WaitKeyCycle
	call bos.fs_CreateFile
	pop bc
mkfile_info:
	ld hl,mkfile_info_str
	call bos.gui_Print
mkfile_success:
	xor a,a
	sbc hl,hl
	ret
mkfile_info_str:
	db "Usage: MKFILE [file]",0
end fs_file


end fs_fs
