
	jr rm_main
	db "FEX",0
rm_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr c,.info
	syscall _argv_1
	ld a,(hl)
	cp a,'-'
	ld c,0
	jr nz,.rm_file
	inc hl
	ld a,(hl)
	cp a,'r'
	jr nz,.info
	syscall _argv_2
	ld c,$FF
.rm_file:
	push bc,hl
	call bos.fs_OpenFile
	ex (sp),hl
	pop iy,bc
	ld a,(iy + bos.fsentry_fileattr)
	bit fb_subdir, a
	; jr z,.check_readonly
	jr z,.delete
	and a,c ; this only destroys A if C is not 0xff. In this case, if C is 0 we should throw an error. Which means we won't need to preserve A. \m/
	jr z,.fail_subdir
; .check_readonly:
	; bit fb_readonly, a
	; jr nz,.fail_readonly
.delete:
	push hl
	call bos.fs_DeleteFile
	pop bc
	jr .return_0
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.return_0:
	xor a,a
	sbc hl,hl
	jr .exit
.fail_subdir:
	ld hl,.string_subdir
	call bos.gui_PrintLine
	ld hl,2
	; jr .exit
; .fail_readonly:
	; ld hl,.string_readonly
	; call bos.gui_PrintLine
	; ld hl,1
.exit:
	ld sp,ix
	pop ix
	ret
.infostr:
	db "rm [-r] file",0
; .string_readonly:
	; db "Read only file cannot be removed.",0
.string_subdir:
	db "Cannot remove subdir without -r",0

