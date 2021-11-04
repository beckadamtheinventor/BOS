
; shared memory access code for os executables

	jp osrt.check_address_writable
	jp osrt.read_a_from_addr
	jp osrt.read_byte_from_addr
	jp osrt.read_word_from_addr
	jp osrt.read_int_from_addr
	jp osrt.read_long_from_addr
	jp osrt.set_a_at_addr
	jp osrt.set_byte_at_addr
	jp osrt.set_word_at_addr
	jp osrt.set_int_at_addr
	jp osrt.set_long_at_addr

; input a number of bytes to read
; input hl address to read from
osrt.read_a_from_addr:
	dec a
	dec a
	jr z,osrt.read_word_from_addr
	dec a
	jr z,osrt.read_int_from_addr
	dec a
	jr z,osrt.read_long_from_addr
osrt.read_byte_from_addr:
	ld a,(hl)
	or a,a
	sbc hl,hl
	ld l,a
	ret
osrt.read_word_from_addr:
	ld de,(hl)
	ex.s hl,de
	ret
osrt.read_int_from_addr:
	ld hl,(hl)
	ret
osrt.read_long_from_addr:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	ld a,(de)
	ld e,a
	ret

; input a number of bytes to write
; input hl address to write to
; input c|bc|ubc|eubc data to write
osrt.set_a_at_addr:
	dec a
	dec a
	jr z,osrt.set_word_at_addr
	dec a
	jr z,osrt.set_int_at_addr
	dec a
	jr z,osrt.set_long_at_addr
osrt.set_byte_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	ld (hl),c
osrt.return_cf:
	sbc hl,hl
	ret
osrt.set_word_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	ld (hl),b
	dec hl
	ld (hl),c
	jr osrt.return_cf
osrt.set_int_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	dec hl
	dec hl
	ld (hl),bc
	ret
osrt.set_long_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_long_at_addr_fail
	ld (hl),e
	dec hl
	dec hl
	dec hl
	ld (hl),bc
	ret

osrt.set_long_at_addr_fail:
	sbc hl,hl
	ret

osrt.check_address_writable:
	push hl,bc
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,osrt.popbchl_return
	ld bc,$D52C00 - $D00000
	sbc hl,bc
	ccf ;Cf set if address greater than or equal to $D52C00
	jr c,osrt.popbchl_return
	ld bc,ti.stackTop - $D52C00
	sbc hl,bc
	scf ;only affects Cf
	jr z,osrt.popbchl_return
	ccf
osrt.popbchl_return:
	pop bc,hl
	ret
