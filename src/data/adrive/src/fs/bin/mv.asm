
	jr mv_main
	db "FEX",0
mv_main:
	ld hl,-9
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
	jq c,.fail
	ex hl,de
	pop bc
	ld (ix-3),de
	ld hl,(ix+6)
	ldir
	xor a,a
	ld (de),a ;end the new arg0 string
	ld hl,(ix-3) ;check for source file
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.failnotfound
	bit bos.fd_subdir,a
	jq nz,.failsubdir
	ld (ix-9),hl
	ld hl,(ix-6) ;check for destination file
	push hl
	call bos.fs_OpenFile
	pop bc
	jq nc,.maybeoverwrite
.continue:
	ld hl,(ix-6)
	push hl
	call bos.fs_ParentDir
	pop bc
	jq c,.failtowrite
	push hl
	call bos.fs_GetFilePtr
	add hl,bc
	pop bc
	
	jq .done
.maybeoverwrite: ;destination file exists
	ld bc,bos.fsentry_fileattr
	add hl,bc
	bit bos.fd_readonly,(hl)
	jq nz,.failtooverwritero
	ld hl,.overwritestr
	call bos.gui_PrintLine
.overwritewaitkeyloop:
	call bos.sys_WaitKeyCycle
	cp a,34
	jq z,.dooverwrite
	cp a,9
	jq z,.dooverwrite
	cp a,44
	jq z,.done
	cp a,15
	jq z,.done
	jq .overwritewaitkeyloop
.dooverwrite:
	ld hl,(ix-6)
	push hl
	call bos.fs_DeleteFile
	pop bc
	jq nc,.continue
.failtooverwritero:
	ld hl,.failtooverwriterostr
	jq .printandfail
.failmemory:
	ld hl,.failmemorystr
	jq .printandfail
.failnotfound: ;source file not found
	ld hl,.filenotfound
	jq .printandfail
.failtooverwritedir:
	ld hl,.failtooverwritedirstr
	jq .printandfail
.failsubdir:
	ld hl,.failsubdirstr
	jq .printandfail
.failtowrite:
	ld hl,.failtowritestr
.printandfail:
	call bos.gui_PrintLine
	scf
	sbc hl,hl
	jq .exit
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
	db "cp source destination",0
.filenotfound:
	db "Source file not found.",0
.failtooverwritedirstr:
	db "Cannot overwrite directory.",0
.failtooverwriterostr:
	db "Cannot overwrite readonly file.",0
.failmemorystr:
	db "Not enough available RAM.",0
.overwritestr:
	db "Overwrite? Y/N",0
