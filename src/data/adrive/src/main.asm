
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'


fs_fs $041000


fs_file "BOOT", "EXE", f_readonly+f_system
	jr boot_main
	db "FEX",0
boot_main:
	ld hl,boot_script
	push hl
	call bsh_main
	pop bc
	ret
boot_script:
	db "CLS",0
	db "CLEAN",0
	db "BBS C:/HOME/USER.BBS",0
	db "EXPLORER",0
	db "RETURN",0
end fs_file


fs_file "BSH", "EXE", f_readonly+f_system
	jr bsh_main
	db "FEX",0
bsh_main:
	ld iy,bsh_commands-6
.loop:
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



fs_file "CD", "EXE", f_readonly+f_system
	jr cd_main
	db "FEX",0
cd_main:
	pop bc
	pop hl
	push hl
	push bc
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
	ld de,bos.current_working_dir
	push hl,de
	call ti._strcpy
	pop de
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	ld (hl),0
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
str_DirDoesNotExist:
	db $9,"Directory does not exist.",$A,0
	
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
	jr explorer_main
	db "FEX",0
explorer_main:
	ret
end fs_file


; fs_file "MAN", "", f_readonly+f_system+f_subdir
	; fs_subdir 1
	; end fs_subdir
; end fs_file


fs_file "MAN", "EXE", f_readonly+f_system
	jr man_main
	db "FEX",0
man_main:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	call ti._strlen
	ld bc,7+5
	add hl,bc
	push hl
	call bos.sys_Malloc
	pop bc
	ex hl,de
	pop hl ;argument
	push de
	push hl
	ld bc,7
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
	push de,hl,bc
	call bos.fs_GetSectorPtr
	pop bc,de,iy
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
man_EndOfFileReached:
	db $9,"--EOF REACHED--",$A
man_NotFound:
	db "No matching manual found.",0
man_dir:
	db "A:/MAN/",0
man_extension:
	db ".MAN",0
end fs_file


fs_file "LS", "EXE", f_readonly+f_system
	jr ls_main
	db "FEX",0
ls_main:
	ret
end fs_file


end fs_fs
