;@DOES Zx7 compress a block of memory.
;@INPUT int util_Zx7Compress(void *dest, void *src, int len, void (*progress_callback)(int src_offset));
;@OUTPUT length in bytes written to dest.
util_Zx7Compress:
virtual at 1
    .zx7_bits_byte              rb 1
    .zx7_bits_byte_remaining    rb 1
    .callback_cooldown          rb 1
    .zx7_bits_byte_ptr          rb 3
    .source_ptr                 rb 3
    .dest_ptr                   rb 3
    .source_remaining           rb 3
    .current_pattern_cost       rb 3
    .current_pattern_length     rb 3
    .current_pattern_offset     rb 3
    .current_search_ptr         rb 3
    .current_search_remaining   rb 3
    .tmp_pattern_length         rb 3
    .stack_depth:
end virtual
.callback_cooldown_amount := 32
	ld hl,-.stack_depth
	call ti._frameset
	ld hl,(ix+9)
	ld bc,(ix+12)
	ld de,(ix+6)
    ld (ix-.callback_cooldown),.callback_cooldown_amount
	ld (ix-.zx7_bits_byte),0 ; zx7 bit byte
	ld (ix-.zx7_bits_byte_remaining),8 ; zx7 bit byte bits remaining
	ld a,(hl)
	ld (de),a
	inc de
	ld (ix-.zx7_bits_byte_ptr),de ; pointer to zx7 bit byte
	inc de
	inc hl
	dec bc
	ld (ix-.source_ptr),hl ; current source pointer
	ld (ix-.dest_ptr),de ; current output pointer
	ld (ix-.source_remaining),bc ; remaining source bytes
.compressloop:
    dec (ix-.callback_cooldown)
    call z,.do_callback
	call .locate_pattern
	call .write_pattern_or_literal
	ld bc,(ix-.source_remaining)
	ld a,(ix+2-.source_remaining)
	or a,b
	or a,c
	jr nz,.compressloop

	scf
	call .write_bit
	ld b,16
.terminus_loop:
	or a,a
	call .write_bit
	djnz .terminus_loop
	scf
	call .write_bit
	
.shift_final_byte:
	call .write_zero_bit
	jr nz,.shift_final_byte

	ld hl,(ix-.dest_ptr)
	ld bc,(ix+6)
	or a,a
	sbc hl,bc
	ld sp,ix
	pop ix
	ret

.locate_pattern:
	ld hl,(ix-.source_ptr)
	ld a,(hl)
	dec hl
	push hl
	ld hl,$090000
	ld (ix-.current_pattern_cost),hl
	mlt hl
	inc l
	ld (ix-.current_pattern_length),hl
	ld (ix-.current_pattern_offset),hl

	pop hl
	ld de,(ix+9)
	or a,a
	sbc hl,de
	push hl
	push hl
	ld bc,2176
	or a,a
	sbc hl,bc
	pop hl
	pop bc
	inc bc
	jr c,.under_max_offset
	ld bc,2176
.under_max_offset:
	add hl,de
.locate_pattern_loop:
	cpdr
	ret po
	ld (ix-.current_search_ptr),hl
	ld (ix-.current_search_remaining),bc
	inc hl
.located_pattern:
	ld iy,(ix-.source_ptr) ; read ptr
	push hl
	pop de
	ld bc,65536 ; max offset
	add hl,bc
	ld bc,(ix-.source_remaining)
.pattern_check_loop:
	dec bc
	ld a,b
	or a,c
	jr z,.done_pattern_loop
	sbc hl,de
	add hl,de
	jr c,.done_pattern_loop
	inc de
	inc iy
	ld a,(de)
	cp a,(iy)
	jr z,.pattern_check_loop
.done_pattern_loop:
	lea hl,iy
	ld de,(ix-.source_ptr)
	scf
	sbc hl,de ; hl = pattern length - 1
	ld (ix-.tmp_pattern_length),hl
	ld a,h
	or a,l
	ret z
	ld a,10
.cost_loop:
	add a,2
	rr h
	rr l
	jr nz,.cost_loop
	lea hl,iy
	or a,a
	sbc hl,de ; hl = pattern offset
	push hl
	ld de,129
	sbc hl,de
	jr c,.offset_under_128
	add a,4
.offset_under_128:
	; divide cost by length
	; TODO: optimize out call to ti._idvrmu
	ld h,a
	ld l,0
	ld b,8
.shift_up_8_loop:
	add hl,hl
	djnz .shift_up_8_loop
	ld bc,(ix-.tmp_pattern_length)
	inc bc
	call ti._idvrmu
	ex de,hl
	ld bc,(ix-.current_pattern_cost) ; pattern length
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.dont_set_cost
	ld (ix-.current_pattern_cost),hl ; cost
	ld hl,(ix-.tmp_pattern_length)
	inc hl
	ld (ix-.current_pattern_length),hl ; length
	pop hl
	ld (ix-.current_pattern_offset),hl ; offset
	db $3e ; ld a,... dummify pop bc
.dont_set_cost:
	pop bc
	ld hl,(ix-.current_search_ptr)
	ld bc,(ix-.current_search_remaining)
	jp .locate_pattern_loop

.write_literal:
	call .write_zero_bit
	ld hl,(ix-.source_ptr)
	ld a,(hl)
	inc hl
	ld (ix-.source_ptr),hl
    call .write_byte
	ld hl,(ix-.source_remaining)
	dec hl
	ld (ix-.source_remaining),hl
	ret

.write_pattern_or_literal:
	ld hl,(ix-.current_pattern_cost)
	ld bc,$090000
	xor a,a
	sbc hl,bc
	add hl,bc
	jr nc,.write_literal ; write literal if it's more efficient
	scf
	call .write_bit
	ld hl,2
	ld bc,(ix-.current_pattern_length) ; length
	dec bc
.write_zero_bits_loop:
	call .write_zero_bit
	add hl,hl
    scf
	sbc hl,bc
	adc hl,bc
	jr c,.write_zero_bits_loop
	ld b,h
	ld c,l
	ld hl,(ix-.current_pattern_length) ; length
	dec hl
.write_length_bits_loop:
	or a,a
	rr b
	rr c
	ld a,b
	or a,c
	jr z,.done_writing_length_bits
	ld a,b
	and a,h
	ld e,a
	ld a,c
	and a,l
	or a,e
	scf
	jr nz,._write_1_bit
	ccf
._write_1_bit:
	call .write_bit
	jr .write_length_bits_loop
.done_writing_length_bits:
	ld hl,(ix-.current_pattern_offset) ; offset
	dec hl
	ld de,128
	or a,a
	ld a,l
	sbc hl,de
	jr nc,.write_offset_over_128
    call .write_byte
.finished_writing_pattern:
	ld bc,(ix-.current_pattern_length)
	ld hl,(ix-.source_ptr)
	add hl,bc
	ld (ix-.source_ptr),hl
	ld hl,(ix-.source_remaining)
	or a,a
	sbc hl,bc
	ld (ix-.source_remaining),hl
	ret

.write_offset_over_128:
	or a,$80
    call .write_byte
	ld bc,1024
.write_offset_over_128_loop:
	or a,a
	sbc hl,bc
	jr c,.write_offset_over_128_loop_dont_write_bit
	scf
	call .write_bit
	db $3E ; dummify next instruction
.write_offset_over_128_loop_dont_write_bit:
	add hl,bc
	rr b
	jr nz,.write_offset_over_128_loop_dontexit
	jr c,.write_offset_over_128_loop_dontexit
	bit 7,c
	jr z,.finished_writing_pattern
	; jr z,.write_offset_over_128_loop_exit
.write_offset_over_128_loop_dontexit:
	rr c
	jr .write_offset_over_128_loop
; .write_offset_over_128_loop_exit:
	; ret

.write_zero_bit:
	or a,a
.write_bit:
	rl (ix-.zx7_bits_byte)
	dec (ix-.zx7_bits_byte_remaining)
	ret nz
	ld a,(ix-.zx7_bits_byte)
	ld de,(ix-.zx7_bits_byte_ptr)
	ld (de),a
	ld (ix-.zx7_bits_byte_remaining),8
	ld de,(ix-.dest_ptr)
	ld (ix-.zx7_bits_byte_ptr),de
	inc de
	ld (ix-.dest_ptr),de
	ret

.write_byte:
	ld de,(ix-.dest_ptr)
	ld (de),a
	inc de
	ld (ix-.dest_ptr),de
    ret


.do_callback:
    ld hl,(ix+15) ; callback
    add hl,bc
    or a,a
    sbc hl,bc
    ret z
; only need to reset the cooldown if the callback is set
; if the callback is null, the cooldown will be 256 instead of .callback_cooldown_amount
; leading to fewer checks
    ld (ix-.callback_cooldown),.callback_cooldown_amount
    ex hl,de
    ld hl,(ix-.source_ptr) ; current source pointer
    ld bc,(ix+9) ; void* src
    or a,a
    sbc hl,bc
    push hl
    ex hl,de
    call sys_jphl
    pop bc
    ret


