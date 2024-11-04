
	jr fsutil_start
	db "FEX",0
fsutil_start:
	ld hl,-3
	call ti._frameset
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
	ld (ix-3),hl
.next:
	ld hl,(ix-3)
	ld a,(hl)
	inc hl
	ld (ix-3),hl
	cp a,'h'
	jr z,.info
	cp a,'m'
	jr z,.rebuild_cmap
	cp a,'s'
	jr z,.sanity_check
	cp a,'c'
	jr nz,.done
	call bos.fs_GarbageCollect
	jr .done
.rebuild_cmap:
	call bos.fs_InitClusterMap
	jr .next
.sanity_check:
	call bos.fs_SanityCheck
	jr .next
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.done:
	ld hl,bos.return_code_flags
	set bos.bReturnNotError,(hl)
	or a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.infostr:
	db "-h  show this info",$A
	db "-s  run sanity check",$A
	db "-c  cleanup the filesystem",$A
	db "-m  rebuild cluster map",$A
	db "eg. fsutil -mc",0
