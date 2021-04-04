
	jr fsutil_start
	db "FEX",0
fsutil_start:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	inc hl
	or a,a
	jq z,.info
	cp a,'-'
	jq nz,.info
	ld a,(hl)
	inc hl
	cp a,'h'
	jq z,.info
	cp a,'c'
	jq nz,.info
	call bos.fs_GarbageCollect
	jq .done
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
	ret
.infostr:
	db "fsutil -h        show this info",$A
	db "fsutil -c        cleanup the filesystem",0
