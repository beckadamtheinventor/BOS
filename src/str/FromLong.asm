;@DOES Convert num to a base-10 string.
;@INPUT char *str_FromLong(char *dest, uint32_t num);
str_FromLong:
	push iy
	ld iy,0
	add iy,sp
	ld hl,(iy+9)
	ld a,(iy+12)
	ld iy,(iy+6)
	pop bc
	push iy,bc
	ld e,1000000000 shr 24
	ld bc,1000000000 and $FFFFFF
	call .num_to_str_aqu
	ld e,100000000 shr 24
	ld bc,100000000 and $FFFFFF
	call .num_to_str_aqu
	ld e,0
.long_to_str_10m:
	ld bc,10000000
	call .num_to_str_aqu
	ld bc,1000000
	call .num_to_str_aqu
	ld bc,100000
	call .num_to_str_aqu
.long_to_str_10k:
	ld bc,10000
	call .num_to_str_aqu
	ld bc,1000
	call .num_to_str_aqu
.long_to_str_100:
	ld bc,100
	call .num_to_str_aqu
	ld c,10
	call .num_to_str_aqu
	ld c,1
	call .num_to_str_aqu
	ld (iy),0
	pop iy,hl
.skip_zeroes_loop:
	ld a,(hl)
	or a,a
	jr z,.return_single_zero
	cp a,'0'
	ret nz
	inc hl
	jr .skip_zeroes_loop
.return_single_zero:
	dec hl
	ret

.num_to_str_aqu:
	ld d,'0'-1
.num_to_str_aqu.loop:
	inc d
	or a,a
	sbc hl,bc
	sbc a,e
	jr nc,.num_to_str_aqu.loop
	add hl,bc
	adc a,e
	ld (iy),d
	inc iy
	ret
