
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bosfs.inc'
include 'include/defines.inc'

org $043000


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
	ld de,current_working_dir
.copy:
	push hl
	push de
	call ti._strcpy
	pop bc,bc
.exit:
	pop ix
	xor a,a
	ret
end fs_file

