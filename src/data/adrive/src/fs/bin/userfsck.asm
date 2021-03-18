	jq userfsck_main
	db "FEX",0
userfsck_main:
	push ix
	ld ix,userfsck_default_dirs
.loop:
	ld a,(ix)
	or a,a
	jq z,.exit
	pea ix
	call bos.fs_OpenFile
	call c,bos.fs_CreateDir
	pop bc
	lea ix,ix+16
	jq .loop
.exit:
	pop ix
	or a,a
	sbc hl,hl
	ret
userfsck_default_dirs:
	pad_db "/home/user", 0, 16
	pad_db "/usr/bin", 0, 16
	pad_db "/usr/tivars", 0, 16
	pad_db "/usr/lib", 0, 16
	db 0

