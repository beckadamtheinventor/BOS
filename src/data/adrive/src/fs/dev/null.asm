	db $C9, 1
	jp dev_null_retnull
	jp dev_null_retnull
	jp dev_null_get_location
	jp dev_null_read
	jp dev_null_write
	ret
dev_null_get_location:
	ld hl,$FF0000
	ret
dev_null_read:
	pop hl,de,bc
	push bc,de,hl
	ld hl,$FF0000
	ldir
	ret
dev_null_write:
	pop hl,de,bc
	push bc,de,hl
	add hl,bc
	ex hl,de
	ld hl,$FF0000
	add hl,bc
	ex hl,de
	ld bc,0
	ret
dev_null_retnull:
	or a,a
	sbc hl,hl
	ret

