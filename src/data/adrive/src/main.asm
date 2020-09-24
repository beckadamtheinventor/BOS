
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/bos.inc'

org $043000

display_sector "BOOT.EXE", $
fs_file "BOOT", "EXE", f_readonly+f_system
	jr boot_main
	db "FEX",0
boot_main:
	ld hl,boot_script
	push hl
	call bbas_main
	pop bc
	ret
boot_script:
	db "CD C:/",$A
	db "BBS home/user.bbs",$A
	db "EXPLORER",$A
	db "RETURN",$A
end fs_file

display_sector "CD.EXE", $
fs_file "CD", "EXE", f_readonly+f_system
	jr cd_main
	db "FEX",0
cd_main:
	call ti._frameset0
	ld hl,(ix+6)
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jr z,.abspath
	push hl
	call ti._strcpy
	ex (sp),hl
	pop bc
	ex hl,de
	add hl,bc
	ex hl,de
	jr .copy
.abspath:
	ld de,bos.current_working_dir
.copy:
	push hl
	push de
	call bos.fs_CheckDirExists
	jr c,.fail
	call ti._strcpy
	pop bc,bc
.exit:
	pop ix
	xor a,a
	ret
.fail:
	pop bc,bc
	pop ix
	ret
end fs_file

display_sector "BBS.EXE", $
fs_file "BBS", "EXE", f_readonly+f_system
	jr bbas_main
	db "FEX",0
bbas_main:
	call ti._frameset0
	ld hl,(ix+6)
	ld ix,bbas_commands-6
.loop:
	lea ix,ix+6
	push hl
	ld hl,(ix)
	add hl,bc
	or a,a
	sbc hl,bc
	pop de
	jr z,.runexec
	push de
	push hl
	call ti._strlen
	pop bc
	ex (sp),hl
	push bc
	push hl
	call ti._strncmp
	pop bc
	pop hl
	pop hl
	or a,a
	ld de,.loop
	push de
	ret nz
	add hl,bc
	push hl
	ld hl,(ix+3)
	ex (sp),hl
	ret  ;will return to command handler subroutine, and afterwards to the loop.
.runexec:
	push de
	call bos.sys_ExecuteFile
	pop bc
	pop ix
	ret c
	xor a,a
	ret
bbas_commands:
	dl 0
end fs_file

display_sector "EXPLORER.EXE", $
fs_file "EXPLORER", "EXE", f_readonly+f_system
	jr explorer_main
	db "FEX",0
explorer_main:
	ret
end fs_file

display_sector "MAN.EXE", $
fs_file "MAN", "EXE", f_readonly+f_system
	jr man_main
	db "FEX",0
man_main:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	call bos.fs_GetPathLastName
	pop bc
	ld de,bos.InputBuffer
	push de
	ld bc,8
	ldir
	ld hl,man_extension
	ld c,5
	ldir
	call bos.fs_OpenFile
	pop bc
	call bos.fs_GetSectorPtr
	
	
	ret
man_extension:
	db ".man",0
end fs_file



