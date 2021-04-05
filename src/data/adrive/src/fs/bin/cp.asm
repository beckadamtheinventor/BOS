
	jr cp_main
	db "FEX",0
cp_main:
	ld hl,-13
	call ti._frameset
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.info ;if no args display info
	ld bc,' '
	push bc,hl
	call ti._strchr ;find first ' '
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.info ;if ' ' not found display info
	inc hl
	ld (ix-6),hl ;strchr(args, ' ') + 1
	dec hl
	ld bc,(ix+6)
	or a,a
	sbc hl,bc ;strchr(args, ' ') - args
	push hl
	call bos.sys_Malloc ;basically copy arg0 into a malloc'd buffer
	ex hl,de
	pop bc
	ld (ix-3),de
	ld hl,(ix+6)
	ldir
	xor a,a
	ld (de),a ;end the new arg0 string
	ld hl,(ix-3) ;check for source file
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq c,.failnotfound
	bit bos.fd_subdir,a
	jq nz,.failsubdir
	ld (ix-13),a
	ld (ix-9),hl
	ld (ix-12),bc
	ld hl,(ix-6) ;check for destination file
	push hl
	call bos.fs_OpenFile
	pop bc
	jq nc,.maybeoverwrite
.continue:
	ld hl,(ix-9) ;pointer to source file
	ld bc,(ix-12) ;length of source file
	push bc,hl
	ld hl,(ix-6) ;destination file path
	ld c,(ix-13) ;source file flags
	res bos.fd_readonly,c
	push bc,hl
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc
	jq c,.failtowrite
	jq .done
.maybeoverwrite: ;destination file exists
	ld bc,$B
	add hl,bc
	bit bos.fd_subdir,(hl)
	jq nz,.failtooverwritedir
	bit bos.fd_readonly,(hl)
	jq nz,.failtooverwritero
	ld hl,.overwritestr
	call bos.gui_PrintLine
.overwritewaitkeyloop:
	call bos.sys_WaitKeyCycle
	cp a,34
	jq z,.continue
	cp a,9
	jq z,.continue
	cp a,44
	jq z,.done
	cp a,15
	jq z,.done
	jq .overwritewaitkeyloop
.failnotfound: ;source file not found
	ld hl,.filenotfound
	jq .printanddone
.failtooverwritedir:
	ld hl,.failtooverwritedirstr
	jq .printanddone
.failtooverwritero:
	ld hl,.failtooverwriterostr
	jq .printanddone
.failsubdir:
	ld hl,.failsubdirstr
	jq .printanddone
.failtowrite:
	ld hl,.failtowritestr
	jq .printanddone
.info:
	ld hl,.infostring
.printanddone:
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.infostring:
	db "cp source destination",0
.filenotfound:
	db "Source file not found.",0
.failsubdirstr:
	db "Cannot copy directory.",0
.failtooverwritedirstr:
	db "Cannot overwrite directory.",0
.failtooverwriterostr:
	db "Cannot overwrite readonly file.",0
.failtowritestr:
	db "Failed to write destination file.",0
.overwritestr:
	db "Overwrite? Y/N",0
