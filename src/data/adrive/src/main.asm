
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'


fs_fs $041000


fs_file "APRG","EXE", f_readonly+f_system
	jr aprg_main
	db "FEX",0
aprg_main:
	pop bc
	pop hl
	push hl
	push bc
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
	db "BSH C:/HOME/USER.BBS",0
	db "EXPLORER",0
	db "CLEAN",0
	db "CLS",0
	db "RETURN",0
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
	ld iy,bsh_commands-6
.loop:
	push hl
	call bos.sys_GetKey
	pop hl
	cp a,53
	jq z,.keyboard_interrupt
	lea iy,iy+6
	push hl
	ld hl,(iy)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.runexec
	push hl
	call ti._strlen
	pop bc
	ex (sp),hl
	push bc
	push hl
	call ti._strncmp
	pop hl
	pop de
	pop bc
	ld de,.loop
	push de
	ret nz
	add hl,bc
	ld iy,(iy+3)
	jp (iy)  ;will return to command handler subroutine, and afterwards to the loop.
.keyboard_interrupt:
	ld hl,str_KeyboardInterrupt
	call bos.gui_Print
	xor a,a
	ret
.runexec:
	call ti._strlen
	ex (sp),hl
	pop bc
	push bc,hl
	ld a,' '
	cpir
	ld (bos.fsOP6),hl ;save arguments
	pop hl,bc
	push hl
	inc hl
	add hl,bc ;next line in program
	ex (sp),hl
	ld bc,(bos.fsOP6) ;arguments
	push bc,hl
	call bos.sys_ExecuteFile
	pop bc,bc,hl
	jq bsh_main

str_KeyboardInterrupt:
	db $9,"Program execution stopped.",$A,0
bsh_commands:
	dl str_Return, handler_Return
	dl 0, 0
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
	file 'explorer.bin'
end fs_file


fs_file "FEXPLORE", "EXE", f_readonly+f_system
	file 'fexplore.bin'
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
	file 'lib/fatdrvce.bin'
end fs_file

fs_file "FILEIOC","v21", f_readonly+f_system
	file 'lib/fileioc.bin'
end fs_file

fs_file "GRAPHX","v21", f_readonly+f_system
	file 'lib/graphx.bin'
end fs_file

fs_file "SRLDRVCE","v21", f_readonly+f_system
	file 'lib/srldrvce.bin'
end fs_file

fs_file "USBDRVCE","v21", f_readonly+f_system
	file 'lib/usbdrvce.bin'
end fs_file

fs_file "LibLoad", "v21", f_readonly+f_system
	file 'lib/bos_libload.bin'
end fs_file

end fs_fs
