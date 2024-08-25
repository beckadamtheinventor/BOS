;@DOES Find the best unmapped address to sample random numbers from.
;@INPUT void* sys_GetRandomAddress();
;@OUTPUT HL = address
sys_GetRandomAddress:
	ld hl, $D65800
	ld iy, 0
	lea de,iy
	ld c, l
.loop1: ; loops 256 times
	call .test_byte
	dec c
	jr nz,.loop1
.loop2: ; loops 256 times
	call .test_byte
	dec c
	jr nz,.loop2
	call .test_byte ; run a total of 513 times

	ex hl,de
	ld bc,31*8/4 ; change the 31 if the number of tests changes
	xor a,a
	sbc hl,bc
	jr c,.return_default
	add hl,bc

	lea hl, iy+0
	; ld (_sprng_read_addr), hl

	add hl, bc
	xor a, a
	sbc hl, bc  ; set the z flag if HL is 0
	ret z
	inc a
	ret

.return_default:
	ld hl,$D65800
	ret

; test byte at hl, set iy=hl if entropy is better
.test_byte:
	push de
	ld de,0
	ld b,31 ; probably enough tests
.test_byte_outer_loop:
; sample byte twice and bitwise-xor
	ld a,(hl) ; sample 1
	xor a,(hl) ; sample 2
; test the entropy for each of the 8 bits
.test_byte_loop:
	jr z,.done_test_byte_loop
	add a,a ; test next bit (starting with the high bit)
	jr nc,.test_byte_loop ; jump if bit unset
	inc de ; increment score
	jr .test_byte_loop
.done_test_byte_loop:
	djnz .test_byte_outer_loop

	ex (sp),hl ; save pointer to byte, restore current entropy score
; check if the new entropy score is higher than the current entropy score
	or a,a
	sbc hl,de ; current - new
	jr nc,.test_byte_is_worse
	pop iy ; return iy = pointer to byte
	lea hl,iy+1 ; advance pointer to byte for next test
	ret
.test_byte_is_worse:
	ex hl,de ; de = current score
	pop hl ; restore pointer to byte
	inc hl ; advance pointer
	ret
