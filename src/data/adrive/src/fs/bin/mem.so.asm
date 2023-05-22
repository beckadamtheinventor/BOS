
; shared memory access code for os executables

_osrt_mem_so:
	dd 1
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
	jp osrt.xor_val_addr
	jp osrt.or_val_addr
	jp osrt.and_val_addr

virtual
	db "osrt.check_address_writable rb 4", $A
	db "osrt.read_a_from_addr rb 4", $A
	db "osrt.read_byte_from_addr rb 4", $A
	db "osrt.read_word_from_addr rb 4", $A
	db "osrt.read_int_from_addr rb 4", $A
	db "osrt.read_long_from_addr rb 4", $A
	db "osrt.set_a_at_addr rb 4", $A
	db "osrt.set_byte_at_addr rb 4", $A
	db "osrt.set_word_at_addr rb 4", $A
	db "osrt.set_int_at_addr rb 4", $A
	db "osrt.set_long_at_addr rb 4", $A
	db "osrt.xor_val_addr rb 4", $A
	db "osrt.or_val_addr rb 4", $A
	db "osrt.and_val_addr rb 4", $A
	load _routines_osrt_mem_so: $-$$ from $$
end virtual

; input a number of bytes to read
; input hl address to read from
; output uhl|euhl
; preserves bc
osrt.read_a_from_addr:
	dec a
	jr z,osrt.read_byte_from_addr
	dec a
	jr z,osrt.read_word_from_addr
	dec a
	jr z,osrt.read_int_from_addr
osrt.read_long_from_addr:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	ld a,(de)
	ld e,a
	ret
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

; input a number of bytes to write
; input hl address to write to
; input c|bc|ubc|eubc data to write
osrt.set_a_at_addr:
	dec a
	jr z,osrt.set_byte_at_addr
	dec a
	jr z,osrt.set_word_at_addr
	dec a
	jr z,osrt.set_int_at_addr
osrt.set_long_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	ld (hl),e
	dec hl
	dec hl
	dec hl
	ld (hl),bc
	ret
osrt.set_byte_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	ld (hl),c
osrt.return_cf:
	sbc hl,hl
	ret
osrt.set_word_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	ld (hl),b
	dec hl
	ld (hl),c
	jr osrt.return_cf
osrt.set_int_at_addr:
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	inc hl
	call osrt.check_address_writable
	jr c,osrt.set_at_addr_fail
	dec hl
	dec hl
	ld (hl),bc
	ret

osrt.set_at_addr_fail:
	sbc hl,hl
	ret

osrt.check_address_writable:
	push hl,bc
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,osrt.popbchl_return
	; ld bc,$D52C00 - $D00000
	; sbc hl,bc
	; ccf ;Cf set if address greater than or equal to $D52C00
	; jr c,osrt.popbchl_return
	; ld bc,ti.stackTop - $D52C00
	ld bc,ti.stackTop - $D00000
	sbc hl,bc
	scf ;only affects Cf
	jr z,osrt.popbchl_return
	ccf
osrt.popbchl_return:
	pop bc,hl
	ret

; input a = number of bytes to xor
; input hl = address
; input eubc = number
; output euhl = number
osrt.xor_val_addr:
	ld d,a
	ld a,c
	xor a,(hl)
	inc hl
	ld c,a
	dec d
	ret z
	ld a,b
	xor a,(hl)
	inc hl
	ld b,a
	dec d
	ret z
	ld (ti.scrapMem),bc
	ld a,(ti.scrapMem+2)
	xor a,(hl)
	inc hl
	ld (ti.scrapMem+2),a
	ld bc,(ti.scrapMem)
	dec d
	ret z
	ld a,e
	xor a,(hl)
	inc hl
	ld e,a
	dec d
	ret

; input a = number of bytes to or
; input hl = address
; input eubc = number
; output euhl = number
osrt.or_val_addr:
	ld d,a
	ld a,c
	or a,(hl)
	inc hl
	ld c,a
	dec d
	ret z
	ld a,b
	or a,(hl)
	inc hl
	ld b,a
	dec d
	ret z
	ld (ti.scrapMem),bc
	ld a,(ti.scrapMem+2)
	or a,(hl)
	inc hl
	ld (ti.scrapMem+2),a
	ld bc,(ti.scrapMem)
	dec d
	ret z
	ld a,e
	or a,(hl)
	inc hl
	ld e,a
	dec d
	ret

; input a = number of bytes to and
; input hl = address
; input eubc = number
; output eubc = number
osrt.and_val_addr:
	ld d,a
	ld a,c
	and a,(hl)
	inc hl
	ld c,a
	dec d
	ret z
	ld a,b
	and a,(hl)
	inc hl
	ld b,a
	dec d
	ret z
	ld (ti.scrapMem),bc
	ld a,(ti.scrapMem+2)
	and a,(hl)
	inc hl
	ld (ti.scrapMem+2),a
	ld bc,(ti.scrapMem)
	dec d
	ret z
	ld a,e
	and a,(hl)
	inc hl
	ld e,a
	dec d
	ret



