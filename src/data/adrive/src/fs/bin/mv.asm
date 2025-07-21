
	jr mv_main
	db "FEX",0
mv_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,3
	jr nz,.info
	syscall _argv_2
	push hl
	call bos.fs_OpenFile
	jr nc,.failexists
	syscall _argv_1
	push hl
	call bos.fs_OpenFile
	jr c,.failnotfound
	call bos.fs_MoveFile
	jr .done
.failnotfound:
	ld hl,.filenotfoundstr
	jr .printandfail
.failexists:
	ld hl,.fileexistsstr
.printandfail:
	call bos.gui_PrintLine
	scf
	sbc hl,hl
	jr .exit
.info:
	ld hl,.infostring
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
.exit:
	ld sp,ix
	pop ix
	ret
.infostring:
	db "mv source destination",0
.filenotfoundstr:
	db "Source file not found.",0
.fileexistsstr:
	db "Destination file exists.",0
