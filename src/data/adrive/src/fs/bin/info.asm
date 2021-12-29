	jq info_exe_main
	db "FEX",0
info_exe_main:
	call ti._frameset0
	call osrt.argv_1
	push hl
	call bos.fs_OpenFile
	jr c,.fail
	ex (sp),hl
	ld hl,.string_filesize
	call bos.gui_Print
	call bos.fs_GetFDLen
	call bos.gui_PrintInt
	call bos.gui_NewLine
	or a,a
	sbc hl,hl
	db $01
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.string_filesize:
	db "File Size: ",0
; .string_bin:
	; db "Binary file",0
; .string_text:
	; db "Text file",0
; .string_fex:
	; db "Flash EXecutable",0
; .string_rex:
	; db "RAM EXecutable",0

