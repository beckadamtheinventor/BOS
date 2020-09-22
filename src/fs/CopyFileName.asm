
;@DOES copies file name from file descriptor
;@INPUT hl = file descriptor
;@INPUT de = destination string
fs_CopyFileName:
	ld a,(hl)
	or a,a
	jq z,.enda
	cp a,fsentry_deleted
	jq z,.end
	cp a,fsentry_E5
	jq z,.E5
	ld (de),a
	inc de
	cp a,fsentry_dot
	jq z,.end
.enterloop:
	inc hl
	push hl
	ld b,7
.loop:
	ld a,(hl)
	inc hl
	cp a,' '
	jq z,.ext_start
	ld (de),a
	inc de
	djnz .loop
.ext_start:
	pop hl
	ld bc,7
	add hl,bc
	ld a,(hl)
	cp a,' '
	jr z,.end
	ld a,'.'
	ld (de),a
	inc de
.ext:
	ld b,3
.extloop:
	ld a,(hl)
	inc hl
	cp a,' '
	jq z,.end
	ld (de),a
	inc de
	djnz .extloop
.end:
	xor a,a
.enda:
	ld (de),a
	ret
.E5:
	jq .enterloop

