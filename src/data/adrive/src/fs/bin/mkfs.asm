
;TODO: Don't use this yet


	jr mkfs_start
	db "FEX",0
mkfs_start:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	inc hl
	or a,a
	jq z,.info
	cp a,'-'
	jq nz,.mkfs512
	ld a,(hl)
	cp a,'2'
	jq nz,.help
;bosfs256-type filesystem
	inc hl
	ld bc,.bosfs256_default_len
	ld e,0
	push bc,de,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
	ret c
	ld bc,0
	push bc,hl
	ld bc,1
	push bc
	ld bc,.bosfs256_default_sector0_len
	push bc
	ld bc,.bosfs256_default_sector0
	push bc
	call bos.fs_Write
	pop bc,bc,bc,hl,bc
	ld bc,256
	push bc,hl
	ld bc,1
	push bc
	ld bc,.bosfs256_default_sector1_len
	push bc
	ld bc,.bosfs256_default_sector1
	push bc
	call bos.fs_Write
	pop bc,bc,bc,hl,bc
	
	ret
;bosfs512-type filesystem (default)
.mkfs512:
	
	ret
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
	ret
.infostr:
	db "mkfs -h        show this info",$A
	db "mkfs path      make a new bosfs512 filesystem at path",$A
	db "mkfs -2 path   make a new bosfs256 filesystem at path",0

.bosfs256_default_sector0:
	db "bosfs256fs ",0
	dw 1
	dw 32
.bosfs256_default_sector0_len:=$-.bosfs256_default_sector0
.bosfs256_default_sector1:
	db ".          ",1 shl fd_subdir
	dw 1
	dw 32
.bosfs256_default_sector1_len:=$-.bosfs256_default_sector1_len

.bosfs256_default_len:=512

.bosfs512_default_sector0:
	db "bosfs512fs ",0
	dw 1
	dw 32
.bosfs512_default_sector0_len:=$-.bosfs512_default_sector0
.bosfs512_default_len:=1024

