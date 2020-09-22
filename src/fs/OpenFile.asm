
;@DOES Opens a file from a path and returns file descriptor.
;@INPUT hl = path
;@OUTPUT hl = file descriptor
fs_OpenFile:
	ld a,(hl)
	push hl
	call fs_RootDir
	pop de
	push ix
	
.next:
	inc de
	ld a,(de)
	or a,a
	jq z,.return
	cp a,'/'
	jr nz,.next
.return:
	lea hl,ix
	pop ix
	ret

