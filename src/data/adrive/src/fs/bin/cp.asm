
	jr cp_main
	db "FEX",0
cp_main:
	ld hl,-13
	call ti._frameset
	ld a,(ix+6)
	cp a,3
	jr z,.trycopy
.info: ; if no args or incorrect args display info
	ld hl,.infostring
	call bos.gui_PrintLine
	jr .done
.trycopy:
	call osrt.argv_2
	push hl
	call osrt.argv_1
	push hl
	call bos.fs_CopyFile
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.done
	call bos.fs_OpenFile ; destination file
	jr nc,.failtowrite
.check_source_err:
	pop bc
	call bos.fs_OpenFile
	jr c,.failnotfound
	ld bc,bos.fsentry_fileattr
	add hl,bc
	bit bos.fd_subdir,(hl)
	jr nz,.failsubdir
	ld hl,.failunknownerror
	jr .printandfail
.failtowrite: ; failed to write
	ld hl,.failtowritestr
	jr .printandfail
.failnotfound: ; source file not found
	ld hl,.filenotfound
	jr .printandfail
.failsubdir: ; cannot copy directory
	ld hl,.failsubdirstr
	jr .printandfail
.printandfail:
	call bos.gui_PrintLine
.done:
	or a,a
	db $3E
.fail:
	scf
	sbc hl,hl
.exit:
	ld sp,ix
	pop ix
	ret
.infostring:
	db "cp source destination",0
.filenotfound:
	db "Source file not found.",0
.failsubdirstr:
	db "Cannot copy directory.",0
.failtowritestr:
	db "Failed to write destination file.",0
.failunknownerror:
	db "Failed due to an unknown error.",0
