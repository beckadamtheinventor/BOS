
	jr fsutil_start
	db "FEX",0
fsutil_start:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr nz,.info
	call osrt.argv_1
	ld a,(hl)
	inc hl
	or a,a
	jr z,.info
	cp a,'-'
	jr nz,.info
	ld a,(hl)
	inc hl
	cp a,'h'
	jr z,.info
	cp a,'c'
	jr nz,.info
	call bos.fs_GarbageCollect
	jr .done
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
	pop ix
	ret
.infostr:
	db "fsutil -h        show this info",$A
	db "fsutil -c        cleanup the filesystem",0
